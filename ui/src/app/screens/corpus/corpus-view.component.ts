import { ChangeDetectionStrategy, Component } from '@angular/core';
import { TranslocoPipe } from '@jsverse/transloco';

@Component({
  selector: 'dp-it-giurisprudenza-corpus-view',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslocoPipe],
  templateUrl: './corpus-view.component.html',
  styleUrl: './corpus-view.component.css',
})
export class CorpusViewComponent {}
