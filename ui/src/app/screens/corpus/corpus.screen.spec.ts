import { TestBed, type ComponentFixture } from '@angular/core/testing';
import { must } from '../../testing/dom';
import { cassWire, ccHitWire, cgtWire, listWire } from '../../testing/giu-fixtures';
import { callsOf, stubGiuEnvironment } from '../../testing/stub-giu-tools';
import { giuProviders } from '../../providers';
import { CorpusScreen } from './corpus.screen';

type Handler = (input: object) => unknown;

interface Handlers {
  readonly list?: Handler;
  readonly search?: Handler;
  readonly cass?: Handler;
  readonly cgt?: Handler;
}

function setup(handlers: Handlers, overrides: Parameters<typeof stubGiuEnvironment>[1] = {}) {
  const env = stubGiuEnvironment(
    {
      pronunce_list: handlers.list ?? (() => []),
      search: handlers.search ?? (() => []),
      cassazione_search: handlers.cass ?? (() => []),
      cgt_search: handlers.cgt ?? (() => []),
    },
    { locale: 'en', ...overrides },
  );
  TestBed.configureTestingModule({ providers: [...giuProviders] });
  const fixture = TestBed.createComponent(CorpusScreen);
  fixture.componentRef.setInput('context', env.context());
  return { env, fixture };
}

type Fixture = ComponentFixture<CorpusScreen>;

async function settle(fixture: Fixture, ms = 0): Promise<void> {
  await vi.advanceTimersByTimeAsync(ms);
  fixture.detectChanges();
  for (let i = 0; i < 3; i++) {
    await vi.advanceTimersByTimeAsync(0);
    fixture.detectChanges();
  }
}

const root = (fixture: Fixture): HTMLElement => fixture.nativeElement as HTMLElement;
const all = (fixture: Fixture, id: string): HTMLElement[] => [...root(fixture).querySelectorAll<HTMLElement>(`[data-testid="${id}"]`)];
const el = (fixture: Fixture, id: string): HTMLElement => must(root(fixture), `[data-testid="${id}"]`);

function type(fixture: Fixture, id: string, value: string): void {
  const input = el(fixture, id) as HTMLInputElement;
  input.value = value;
  input.dispatchEvent(new Event('input'));
}

function choose(fixture: Fixture, id: string, value: string): void {
  const select = el(fixture, id) as HTMLSelectElement;
  select.value = value;
  select.dispatchEvent(new Event('change'));
}

const pagedList = (total: number): Handler => (input) => {
  const { offset, limit } = input as { offset?: number; limit?: number };
  const from = offset ?? 0;
  return Array.from({ length: Math.min(limit ?? 50, total - from) }, (_, i) =>
    listWire({ ecli: `ECLI:IT:COST:2026:${String(from + i + 1)}`, numero: from + i + 1, total }),
  );
};

describe('CorpusScreen', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
  });

  describe('Costituzionale tab', () => {
    it('should list decisions with pronunce_list and show ecli, kind and massime count when the Tool returns rows', async () => {
      const { env, fixture } = setup({ list: () => [listWire(), listWire({ ecli: 'ECLI:IT:COST:2026:104', numero: 104, tipologia: 'S' })] });
      fixture.detectChanges();
      await settle(fixture);
      const rows = all(fixture, 'cc-row');
      expect(rows).toHaveLength(2);
      expect(rows[0]?.textContent).toContain('ECLI:IT:COST:2026:95');
      expect(rows[0]?.textContent).toContain('2026-05-14');
      expect(callsOf(env, 'pronunce_list')).toEqual([{ limit: 50, offset: 0 }]);
      expect(callsOf(env, 'search')).toEqual([]);
      expect(callsOf(env, 'cassazione_search')).toEqual([]);
      expect(callsOf(env, 'cgt_search')).toEqual([]);
    });

    it('should ask offset 50 when the next page is chosen', async () => {
      const { env, fixture } = setup({ list: pagedList(120) });
      fixture.detectChanges();
      await settle(fixture);
      expect(all(fixture, 'cc-row')).toHaveLength(50);
      el(fixture, 'cc-next').click();
      await settle(fixture);
      expect(callsOf(env, 'pronunce_list').at(-1)).toEqual({ limit: 50, offset: 50 });
      expect(all(fixture, 'cc-row')[0]?.textContent).toContain('ECLI:IT:COST:2026:51');
      expect((el(fixture, 'cc-prev') as HTMLButtonElement).disabled).toBe(false);
    });

    it('should call search once with the query after the debounce when the user types', async () => {
      const { env, fixture } = setup({ list: () => [listWire()], search: () => [ccHitWire()] });
      fixture.detectChanges();
      await settle(fixture);
      type(fixture, 'cc-search', 'licen');
      await settle(fixture, 100);
      type(fixture, 'cc-search', 'licenziamento');
      await settle(fixture, 100);
      expect(callsOf(env, 'search')).toHaveLength(0);
      await settle(fixture, 400);
      expect(callsOf(env, 'search')).toEqual([{ query: 'licenziamento', k: 50 }]);
      const [hit] = all(fixture, 'cc-row');
      expect(hit?.textContent).toContain('Licenziamento illegittimo');
      expect(el(fixture, 'cc-source-badge').textContent).toContain('massima');
    });

    it('should render the highlight markers as mark text nodes and never as html when the headline holds a script', async () => {
      const headline = 'Il «licenziamento» e <script>window.__x = 1</script> <img src=x onerror="window.__x = 2"> illegittimo';
      const { fixture } = setup({ list: () => [listWire()], search: () => [ccHitWire({ headline })] });
      fixture.detectChanges();
      await settle(fixture);
      type(fixture, 'cc-search', 'licenziamento');
      await settle(fixture, 400);
      const box = el(fixture, 'cc-headline');
      expect([...box.querySelectorAll('mark')].map((mark) => mark.textContent)).toEqual(['licenziamento']);
      expect(box.querySelector('script')).toBeNull();
      expect(box.querySelector('img')).toBeNull();
      expect(box.textContent).toContain('<script>window.__x = 1</script>');
      expect((window as unknown as { __x?: number }).__x).toBeUndefined();
    });

    it('should list a year range with search filter-only and a hint when the years differ and the box is empty', async () => {
      const { env, fixture } = setup({ list: () => [listWire()], search: () => [ccHitWire({ source: 'pronuncia', massima_numero: null, titolo: null })] });
      fixture.detectChanges();
      await settle(fixture);
      type(fixture, 'cc-anno-from', '2000');
      type(fixture, 'cc-anno-to', '2005');
      choose(fixture, 'cc-tipologia', 'S');
      await settle(fixture, 400);
      expect(callsOf(env, 'search').at(-1)).toEqual({ tipologia: 'S', anno_from: 2000, anno_to: 2005, k: 50 });
      expect(el(fixture, 'cc-range-hint').textContent).not.toBe('');
    });

    it('should use pronunce_list with the year when both years are equal', async () => {
      const { env, fixture } = setup({ list: () => [listWire()] });
      fixture.detectChanges();
      await settle(fixture);
      type(fixture, 'cc-anno-from', '2017');
      type(fixture, 'cc-anno-to', '2017');
      await settle(fixture, 400);
      expect(callsOf(env, 'pronunce_list').at(-1)).toEqual({ anno: 2017, limit: 50, offset: 0 });
      expect(callsOf(env, 'search')).toEqual([]);
    });

    it('should show the empty state text when the Tool returns no decisions', async () => {
      const { fixture } = setup({ list: () => [] });
      fixture.detectChanges();
      await settle(fixture);
      expect(all(fixture, 'cc-row')).toHaveLength(0);
      expect(el(fixture, 'cc-empty').textContent).toContain('No decisions');
    });

    it('should show the error state and no rows when the Tool fails', async () => {
      const { fixture } = setup({
        list: () => {
          throw new Error('boom');
        },
      });
      fixture.detectChanges();
      await settle(fixture);
      expect(all(fixture, 'cc-row')).toHaveLength(0);
      expect(el(fixture, 'cc-error').textContent).toContain('could not be loaded');
    });

    it('should navigate with the raw cc key when a row is clicked', async () => {
      const navigateScreen = vi.fn();
      const { fixture } = setup({ list: () => [listWire()] }, { navigateScreen });
      fixture.detectChanges();
      await settle(fixture);
      must(all(fixture, 'cc-row')[0] ?? root(fixture), '[data-testid="cc-open"]').click();
      expect(navigateScreen).toHaveBeenCalledExactlyOnceWith('decision', 'cc~ECLI:IT:COST:2026:95');
    });
  });

  describe('Cassazione tab', () => {
    it('should not call cassazione_search before the tab is chosen and list filter-only when it is', async () => {
      const { env, fixture } = setup({ list: () => [listWire()], cass: () => [cassWire()] });
      fixture.detectChanges();
      await settle(fixture);
      expect(callsOf(env, 'cassazione_search')).toHaveLength(0);
      el(fixture, 'tab-cass').click();
      await settle(fixture);
      expect(callsOf(env, 'cassazione_search')).toEqual([{}]);
      const row = all(fixture, 'cass-row')[0];
      for (const text of ['ECLI:IT:CASS:2025:123', '2025', '123', 'TRIBUTI', 'Estratto della ordinanza di cassazione.']) {
        expect(row?.textContent, text).toContain(text);
      }
    });

    it('should send kind and anno_from when the filters are set', async () => {
      const { env, fixture } = setup({ cass: () => [cassWire()] });
      fixture.detectChanges();
      el(fixture, 'tab-cass').click();
      await settle(fixture);
      choose(fixture, 'cass-kind', 'snciv');
      type(fixture, 'cass-anno-from', '2021');
      await settle(fixture, 400);
      expect(callsOf(env, 'cassazione_search').at(-1)).toEqual({ kind: 'snciv', anno_from: 2021 });
    });

    it('should call cassazione_search with the query after the debounce when the user types', async () => {
      const { env, fixture } = setup({ cass: () => [cassWire()] });
      fixture.detectChanges();
      el(fixture, 'tab-cass').click();
      await settle(fixture);
      type(fixture, 'cass-search', 'tributi');
      await settle(fixture, 400);
      expect(callsOf(env, 'cassazione_search').at(-1)).toEqual({ query: 'tributi' });
    });

    it('should show the snippet unaltered and an https source link when the snippet is long', async () => {
      const snippet = 'Estratto '.repeat(250).trim();
      const { fixture } = setup({ cass: () => [cassWire({ snippet })] });
      fixture.detectChanges();
      el(fixture, 'tab-cass').click();
      await settle(fixture);
      expect(el(fixture, 'cass-snippet').textContent.trim()).toBe(snippet);
      const link = el(fixture, 'cass-source-link');
      expect(link.getAttribute('href')).toContain('https://www.italgiure.giustizia.it/');
      expect(link.getAttribute('target')).toBe('_blank');
      expect(link.getAttribute('rel')).toBe('noopener noreferrer');
    });

    it('should render no link when the source url is not https', async () => {
      const { fixture } = setup({ cass: () => [cassWire({ source_url: 'javascript:alert(1)' })] });
      fixture.detectChanges();
      el(fixture, 'tab-cass').click();
      await settle(fixture);
      expect(all(fixture, 'cass-source-link')).toHaveLength(0);
    });

    it('should show the empty state when nothing matches', async () => {
      const { fixture } = setup({ cass: () => [] });
      fixture.detectChanges();
      el(fixture, 'tab-cass').click();
      await settle(fixture);
      expect(el(fixture, 'cass-empty').textContent).toContain('No sentences');
    });

    it('should show the error state when the Tool fails', async () => {
      const { fixture } = setup({
        cass: () => {
          throw new Error('boom');
        },
      });
      fixture.detectChanges();
      el(fixture, 'tab-cass').click();
      await settle(fixture);
      expect(el(fixture, 'cass-error').textContent).toContain('could not be loaded');
    });

    it('should navigate with the source id key when a row is clicked', async () => {
      const navigateScreen = vi.fn();
      const { fixture } = setup({ cass: () => [cassWire()] }, { navigateScreen });
      fixture.detectChanges();
      el(fixture, 'tab-cass').click();
      await settle(fixture);
      must(all(fixture, 'cass-row')[0] ?? root(fixture), '[data-testid="cass-open"]').click();
      expect(navigateScreen).toHaveBeenCalledExactlyOnceWith('decision', 'cass~snciv2025000123O');
    });
  });

  describe('Tributaria tab', () => {
    it('should send grado as a number and luogo when the filters are set', async () => {
      const { env, fixture } = setup({ cgt: () => [cgtWire()] });
      fixture.detectChanges();
      el(fixture, 'tab-cgt').click();
      await settle(fixture);
      expect(callsOf(env, 'cgt_search')).toEqual([{}]);
      choose(fixture, 'cgt-grado', '2');
      type(fixture, 'cgt-luogo', 'Campania');
      await settle(fixture, 400);
      expect(callsOf(env, 'cgt_search').at(-1)).toEqual({ grado: 2, luogo: 'Campania' });
      expect(all(fixture, 'cgt-row')[0]?.textContent).toContain('Campania');
    });

    it('should show the empty and the error state', async () => {
      const failing = setup({
        cgt: () => {
          throw new Error('boom');
        },
      });
      failing.fixture.detectChanges();
      el(failing.fixture, 'tab-cgt').click();
      await settle(failing.fixture);
      expect(el(failing.fixture, 'cgt-error').textContent).toContain('could not be loaded');
    });

    it('should navigate with the cgt key when a row is clicked', async () => {
      const navigateScreen = vi.fn();
      const { fixture } = setup({ cgt: () => [cgtWire()] }, { navigateScreen });
      fixture.detectChanges();
      el(fixture, 'tab-cgt').click();
      await settle(fixture);
      must(all(fixture, 'cgt-row')[0] ?? root(fixture), '[data-testid="cgt-open"]').click();
      expect(navigateScreen).toHaveBeenCalledExactlyOnceWith('decision', 'cgt~3f2b8c1e-6d3a-4a52-9f0e-1c2d3e4f5a6b');
    });
  });

  it('should render Slovak texts when the locale is sk', async () => {
    const { fixture } = setup({ list: () => [] }, { locale: 'sk' });
    fixture.detectChanges();
    await settle(fixture);
    expect(el(fixture, 'cc-empty').textContent).toContain('Žiadne rozhodnutia');
  });

  it('should render Italian texts when the locale is it', async () => {
    const { fixture } = setup({ list: () => [] }, { locale: 'it' });
    fixture.detectChanges();
    await settle(fixture);
    expect(el(fixture, 'cc-empty').textContent).toContain('Nessuna decisione');
  });
});
