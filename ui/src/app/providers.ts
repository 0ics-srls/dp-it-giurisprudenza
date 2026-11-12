import { provideZonelessChangeDetection, type EnvironmentProviders, type Provider } from '@angular/core';
import { providePackagePrimeNG } from '@olx/package-ui-sdk';
import { provideGiuI18n } from './i18n/provide-giu-i18n';

/**
 * Application-level providers of the package. No router (Screens render from `subPath`); `GiuTools` is provided by
 * each root because it needs the context that root connects.
 */
export const giuProviders: readonly (Provider | EnvironmentProviders)[] = [
  providePackagePrimeNG({ packageName: 'it-giurisprudenza' }),
  provideGiuI18n(),
  provideZonelessChangeDetection(),
];
