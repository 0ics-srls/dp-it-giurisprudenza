import { APP_ROOT, flattenKeys, templateKeys } from '../testing/source-scan';
import enDict from './en.json';
import itDict from './it.json';
import skDict from './sk.json';

describe('dictionaries', () => {
  it('should have the same keys in sk, en and it when compared', () => {
    const keys = flattenKeys(enDict).sort();
    expect(flattenKeys(skDict).sort()).toEqual(keys);
    expect(flattenKeys(itDict).sort()).toEqual(keys);
  });

  it('should define every literal key used in a template when the sources are scanned', () => {
    const defined = new Set(flattenKeys(enDict));
    const missing = templateKeys(APP_ROOT)
      .filter((used) => !defined.has(used.key))
      .map((used) => `${used.key} (${used.path})`);
    expect(missing).toEqual([]);
  });

  it('should have a status note for each corpus in sk, en and it when the dynamic key is built', () => {
    for (const dict of [skDict, enDict, itDict]) {
      const keys = flattenKeys(dict);
      for (const corpus of ['cc', 'cassazione', 'cgt']) {
        expect(keys).toContain(`status.notes.${corpus}`);
      }
    }
  });

  it('should find template keys when scanning (no vacuous pass)', () => {
    expect(templateKeys(APP_ROOT).length).toBeGreaterThan(20);
  });
});
