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
}
