import { ChangeDetectionStrategy, Component } from '@angular/core';
import { TranslocoPipe } from '@jsverse/transloco';

@Component({
  selector: 'dp-it-giurisprudenza-decision-view',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslocoPipe],
  templateUrl: './decision-view.component.html',
  styleUrl: './decision-view.component.css',
})
export class DecisionViewComponent {}
