import { computed, inject, Injectable, signal } from '@angular/core';
import { injectPackageContext } from '@olx/package-ui-sdk';
import { decisionKey } from '../../shared/decision-key';
import { ListStore, toYear } from '../../shared/list-store';
import { textParts, type TextPart } from '../../shared/text-parts';
import { GiuTools } from '../../tools/giu-tools';

export const CC_PAGE_SIZE = 50;

export interface CcQuery {
  readonly text: string;
  readonly tipologia: string;
  readonly annoFrom: number | undefined;
  readonly annoTo: number | undefined;
  readonly offset: number;
}

/** One line of the list, whichever Tool produced it. */
export interface CcItem {
  readonly key: string;
  readonly ecli: string;
  readonly tipologia: string;
  readonly anno: number;
  readonly numero: number;
  readonly dataDeposito: Date | null;
  /** Only the `search` hits: massima or pronuncia. */
  readonly source: 'massima' | 'pronuncia' | null;
  readonly massimaNumero: number | null;
  readonly titolo: string | null;
  readonly headline: readonly TextPart[];
  readonly snippet: string | null;
  readonly sourceUrl: string | null;
  readonly relatore: string | null;
  readonly massimeCount: number | null;
}

/** Which Tool a query uses: text -> search; a range of years without text -> search filter-only; otherwise the paged list. */
export function modeOf(query: CcQuery): 'search' | 'range' | 'list' {
  if (query.text !== '') {
    return 'search';
  }
  const open = query.annoFrom !== undefined || query.annoTo !== undefined;
  return open && query.annoFrom !== query.annoTo ? 'range' : 'list';
}

@Injectable()
export class CcStore extends ListStore<CcQuery, CcItem> {
  private readonly tools = inject(GiuTools);
  private readonly context = injectPackageContext();
  private readonly total = signal(0);

  readonly mode = computed(() => modeOf(this.query()));
  readonly offset = computed(() => this.query().offset);
  readonly paged = computed(() => this.mode() === 'list');

  constructor() {
    super({ text: '', tipologia: '', annoFrom: undefined, annoTo: undefined, offset: 0 }, true);
  }

  readonly count = computed(() => this.total());
  readonly from = computed(() => (this.count() === 0 ? 0 : this.offset() + 1));
  readonly to = computed(() => Math.min(this.offset() + CC_PAGE_SIZE, this.count()));
  readonly hasPrevious = computed(() => this.paged() && this.offset() > 0);
  readonly hasNext = computed(() => this.paged() && this.offset() + CC_PAGE_SIZE < this.count());

  search(text: string): void {
    this.edit({ text: text.trim(), offset: 0 });
  }

  annoFrom(text: string): void {
    this.edit({ annoFrom: toYear(text), offset: 0 });
  }

  annoTo(text: string): void {
    this.edit({ annoTo: toYear(text), offset: 0 });
  }

  tipologia(tipologia: string): void {
    this.choose({ tipologia, offset: 0 });
  }

  next(): void {
    if (this.hasNext()) {
      this.choose({ offset: this.offset() + CC_PAGE_SIZE });
    }
  }

  previous(): void {
    if (this.hasPrevious()) {
      this.choose({ offset: Math.max(0, this.offset() - CC_PAGE_SIZE) });
    }
  }

  open(item: CcItem): void {
    this.context().navigateScreen('decision', decisionKey('cc', item.ecli));
  }

  protected override async readRows(query: CcQuery): Promise<readonly CcItem[]> {
    const tipologia = query.tipologia === '' ? undefined : query.tipologia;
    const mode = modeOf(query);
    if (mode === 'list') {
      const rows = await this.tools.listPronunce({ anno: query.annoFrom, tipologia, limit: CC_PAGE_SIZE, offset: query.offset });
      this.total.set(rows[0]?.total ?? 0);
      return rows.map((row) => ({
        key: row.ecli,
        ecli: row.ecli,
        tipologia: row.tipologia,
        anno: row.anno,
        numero: row.numero,
        dataDeposito: row.dataDeposito,
        source: null,
        massimaNumero: null,
        titolo: null,
        headline: [],
        snippet: null,
        sourceUrl: null,
        relatore: row.relatore,
        massimeCount: row.massimeCount,
      }));
    }
    const hits = await this.tools.searchCc({
      query: mode === 'search' ? query.text : undefined,
      tipologia,
      annoFrom: query.annoFrom,
      annoTo: query.annoTo,
      k: CC_PAGE_SIZE,
    });
    this.total.set(hits.length);
    return hits.map((hit) => ({
      key: `${hit.source}|${hit.ecli}|${String(hit.massimaNumero ?? '')}`,
      ecli: hit.ecli,
      tipologia: hit.tipologia,
      anno: hit.anno,
      numero: hit.numero,
      dataDeposito: hit.dataDeposito,
      source: hit.source,
      massimaNumero: hit.massimaNumero,
      titolo: hit.titolo,
      headline: textParts(hit.headline),
      snippet: hit.snippet,
      sourceUrl: hit.sourceUrl,
      relatore: null,
      massimeCount: null,
    }));
  }
}
