import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { type PackageScreenContext } from '@olx/package-ui-sdk';
import { connectGiuScreen, screenContextProvider } from '../../shared/connect-screen';
import { GiuTools } from '../../tools/giu-tools';
import { StatusStore } from './status.store';
import { StatusViewComponent } from './status-view.component';

/** Root of the dp-it-giurisprudenza-status Screen. The root only wires the context; the view injects what needs it (avoids NG0200). */
@Component({
  selector: 'dp-it-giurisprudenza-status',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [StatusViewComponent],
  providers: [screenContextProvider(() => StatusScreen), GiuTools, StatusStore],
  template: '<dp-it-giurisprudenza-status-view />',
})
export class StatusScreen {
  readonly context = input.required<PackageScreenContext>();

  constructor() {
    connectGiuScreen(this.context);
  }
}
