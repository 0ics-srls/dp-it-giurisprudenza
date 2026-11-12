import { definePackageScreens } from '@olx/package-ui-sdk';
import { giuProviders } from './providers';
import { ELEMENTS } from './screens';

type Define = typeof definePackageScreens;

/** Defines the package elements once; a second load of the bundle finds them defined and does nothing. */
export async function registerGiu(define: Define = definePackageScreens): Promise<void> {
  const tags = Object.keys(ELEMENTS);
  if (tags.every((tag) => customElements.get(tag) !== undefined)) {
    return;
  }
  await define('it-giurisprudenza', ELEMENTS, { providers: giuProviders });
}
