import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { type PackageScreenContext } from '@olx/package-ui-sdk';
import { connectGiuScreen, screenContextProvider } from '../../shared/connect-screen';
import { GiuTools } from '../../tools/giu-tools';
import { DecisionViewComponent } from './decision-view.component';

/** Root of the dp-it-giurisprudenza-decision Screen. The root only wires the context; the view injects what needs it (avoids NG0200). */
@Component({
  selector: 'dp-it-giurisprudenza-decision',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DecisionViewComponent],
  providers: [screenContextProvider(() => DecisionScreen), GiuTools],
  template: '<dp-it-giurisprudenza-decision-view />',
})
export class DecisionScreen {
  readonly context = input.required<PackageScreenContext>();

  constructor() {
    connectGiuScreen(this.context);
  }
}
