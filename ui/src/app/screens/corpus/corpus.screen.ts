import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { type PackageScreenContext } from '@olx/package-ui-sdk';
import { connectGiuScreen, screenContextProvider } from '../../shared/connect-screen';
import { GiuTools } from '../../tools/giu-tools';
import { CassStore } from './cass.store';
import { CcStore } from './cc.store';
import { CgtStore } from './cgt.store';
import { CorpusViewComponent } from './corpus-view.component';

/** Root of the dp-it-giurisprudenza-corpus Screen. The root only wires the context; the view injects what needs it (avoids NG0200). */
@Component({
  selector: 'dp-it-giurisprudenza-corpus',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [CorpusViewComponent],
  providers: [screenContextProvider(() => CorpusScreen), GiuTools, CcStore, CassStore, CgtStore],
  template: '<dp-it-giurisprudenza-corpus-view />',
})
export class CorpusScreen {
  readonly context = input.required<PackageScreenContext>();

  constructor() {
    connectGiuScreen(this.context);
  }
}
