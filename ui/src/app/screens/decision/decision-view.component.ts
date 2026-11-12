import { DatePipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { TranslocoPipe } from '@jsverse/transloco';
import { DecisionStore } from './decision.store';

@Component({
  selector: 'dp-it-giurisprudenza-decision-view',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslocoPipe, DatePipe],
  templateUrl: './decision-view.component.html',
  styleUrl: './decision-view.component.css',
})
export class DecisionViewComponent {
  protected readonly store = inject(DecisionStore);

  protected onNorma(event: Event): void {
    this.store.setNorma((event.target as HTMLInputElement).value);
  }
}
