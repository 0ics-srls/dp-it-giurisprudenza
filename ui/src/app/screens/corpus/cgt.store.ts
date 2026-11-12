import { inject, Injectable } from '@angular/core';
import { injectPackageContext } from '@olx/package-ui-sdk';
import { decisionKey } from '../../shared/decision-key';
import { ListStore, toYear } from '../../shared/list-store';
import { httpsUrl } from '../../shared/safe-url';
import { textParts, type TextPart } from '../../shared/text-parts';
import type { CgtHit } from '../../tools/giu-dto';
import { GiuTools } from '../../tools/giu-tools';

export interface CgtQuery {
  readonly text: string;
  readonly grado: number | undefined;
  readonly luogo: string;
  readonly annoFrom: number | undefined;
  readonly annoTo: number | undefined;
}

export interface CgtItem {
  readonly hit: CgtHit;
  readonly snippet: readonly TextPart[];
  readonly link: string;
}

/** Tributaria tab: extremes, excerpt and link only (posture); loaded when the tab is first opened. */
@Injectable()
export class CgtStore extends ListStore<CgtQuery, CgtItem> {
  private readonly tools = inject(GiuTools);
  private readonly context = injectPackageContext();

  constructor() {
    super({ text: '', grado: undefined, luogo: '', annoFrom: undefined, annoTo: undefined }, false);
  }

  search(text: string): void {
    this.edit({ text: text.trim() });
  }

  grado(value: string): void {
    this.choose({ grado: value === '1' ? 1 : value === '2' ? 2 : undefined });
  }

  luogo(luogo: string): void {
    this.edit({ luogo });
  }

  annoFrom(text: string): void {
    this.edit({ annoFrom: toYear(text) });
  }

  annoTo(text: string): void {
    this.edit({ annoTo: toYear(text) });
  }

  open(item: CgtItem): void {
    this.context().navigateScreen('decision', decisionKey('cgt', item.hit.id));
  }

  protected override async readRows(query: CgtQuery): Promise<readonly CgtItem[]> {
    const hits = await this.tools.searchCgt({
      query: query.text.trim() === '' ? undefined : query.text.trim(),
      grado: query.grado,
      luogo: query.luogo.trim() === '' ? undefined : query.luogo.trim(),
      annoFrom: query.annoFrom,
      annoTo: query.annoTo,
    });
    return hits.map((hit) => ({ hit, snippet: textParts(hit.snippet), link: httpsUrl(hit.sourceUrl) }));
  }
}
