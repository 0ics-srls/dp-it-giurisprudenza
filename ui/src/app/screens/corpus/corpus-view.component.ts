import { DatePipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { TranslocoPipe } from '@jsverse/transloco';
import { CassStore } from './cass.store';
import { CcStore } from './cc.store';
import { CgtStore } from './cgt.store';

export type CorpusTab = 'cc' | 'cass' | 'cgt';

@Component({
  selector: 'dp-it-giurisprudenza-corpus-view',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslocoPipe, DatePipe],
  templateUrl: './corpus-view.component.html',
  styleUrl: './corpus-view.component.css',
})
export class CorpusViewComponent {
  protected readonly cc = inject(CcStore);
  protected readonly cass = inject(CassStore);
  protected readonly cgt = inject(CgtStore);

  /** The tab is component state only (no browser storage). */
  protected readonly tab = signal<CorpusTab>('cc');
  protected readonly tabs: readonly CorpusTab[] = ['cc', 'cass', 'cgt'];

  protected select(tab: CorpusTab): void {
    this.tab.set(tab);
    if (tab === 'cass') {
      this.cass.enable();
    } else if (tab === 'cgt') {
      this.cgt.enable();
    }
  }

  protected value(event: Event): string {
    return (event.target as HTMLInputElement | HTMLSelectElement).value;
  }

}
