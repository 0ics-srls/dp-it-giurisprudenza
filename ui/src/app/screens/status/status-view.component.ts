import { DatePipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { TranslocoPipe } from '@jsverse/transloco';
import { StatusStore } from './status.store';

@Component({
  selector: 'dp-it-giurisprudenza-status-view',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslocoPipe, DatePipe],
  templateUrl: './status-view.component.html',
  styleUrl: './status-view.component.css',
})
export class StatusViewComponent {
  protected readonly store = inject(StatusStore);

  /** The package text of the corpus note (Console language); null for a corpus it does not know, then the Tool note is shown. */
  protected noteKey(corpus: string): string | null {
    return corpus === 'cc' || corpus === 'cassazione' || corpus === 'cgt' ? `status.notes.${corpus}` : null;
  }
}
