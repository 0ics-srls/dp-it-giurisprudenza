import { inject, Injectable } from '@angular/core';
import { injectPackageContext } from '@olx/package-ui-sdk';
import { decisionKey } from '../../shared/decision-key';
import { ListStore, toYear } from '../../shared/list-store';
import { httpsUrl } from '../../shared/safe-url';
import { textParts, type TextPart } from '../../shared/text-parts';
import type { CassazioneHit } from '../../tools/giu-dto';
import { GiuTools } from '../../tools/giu-tools';

export interface CassQuery {
  readonly text: string;
  readonly kind: string;
  readonly annoFrom: number | undefined;
  readonly annoTo: number | undefined;
  readonly sezione: string;
  readonly materia: string;
}

export interface CassItem {
  readonly hit: CassazioneHit;
  /** The snippet with the highlight markers split out; the text itself is never altered or shortened. */
  readonly snippet: readonly TextPart[];
  readonly link: string;
}

const blank = (value: string): string | undefined => (value.trim() === '' ? undefined : value.trim());

/** Cassazione tab: extremes, excerpt and link only (posture); loaded when the tab is first opened. */
@Injectable()
export class CassStore extends ListStore<CassQuery, CassItem> {
  private readonly tools = inject(GiuTools);
  private readonly context = injectPackageContext();

  constructor() {
    super({ text: '', kind: '', annoFrom: undefined, annoTo: undefined, sezione: '', materia: '' }, false);
  }

  search(text: string): void {
    this.edit({ text: text.trim() });
  }

  kind(kind: string): void {
    this.choose({ kind });
  }

  annoFrom(text: string): void {
    this.edit({ annoFrom: toYear(text) });
  }

  annoTo(text: string): void {
    this.edit({ annoTo: toYear(text) });
  }

  sezione(sezione: string): void {
    this.edit({ sezione });
  }

  materia(materia: string): void {
    this.edit({ materia });
  }

  open(item: CassItem): void {
    this.context().navigateScreen('decision', decisionKey('cass', item.hit.sourceId));
  }

  protected override async readRows(query: CassQuery): Promise<readonly CassItem[]> {
    const hits = await this.tools.searchCassazione({
      query: blank(query.text),
      kind: blank(query.kind),
      annoFrom: query.annoFrom,
      annoTo: query.annoTo,
      sezione: blank(query.sezione),
      materia: blank(query.materia),
    });
    return hits.map((hit) => ({ hit, snippet: textParts(hit.snippet), link: httpsUrl(hit.sourceUrl) }));
  }
}
