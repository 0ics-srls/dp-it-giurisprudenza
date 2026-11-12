import type { Type } from '@angular/core';
import { CorpusScreen } from './screens/corpus/corpus.screen';
import { DecisionScreen } from './screens/decision/decision.screen';
import { StatusScreen } from './screens/status/status.screen';

/** Custom elements of the package: three Screens. */
export const ELEMENTS = {
  'dp-it-giurisprudenza-corpus': CorpusScreen,
  'dp-it-giurisprudenza-decision': DecisionScreen,
  'dp-it-giurisprudenza-status': StatusScreen,
} as const satisfies Readonly<Record<string, Type<unknown>>>;
