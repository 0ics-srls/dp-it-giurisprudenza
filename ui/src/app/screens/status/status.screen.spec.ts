import { TestBed, type ComponentFixture } from '@angular/core/testing';
import { must } from '../../testing/dom';
import { statusWire } from '../../testing/giu-fixtures';
import { callsOf, stubGiuEnvironment } from '../../testing/stub-giu-tools';
import { giuProviders } from '../../providers';
import { StatusScreen } from './status.screen';

type Handler = (input: object) => unknown;

const threeRows = (): unknown[] => [
  statusWire(),
  statusWire({
    corpus: 'cassazione',
    documents: 40,
    massime: 0,
    passages: 200,
    passages_without_embedding: 12,
    last_ingested_at: '2026-11-10T09:30:00Z',
    norme_pending: null,
    norme_resolved: null,
    norme_unresolved: null,
    note: 'Solo dal 2021.',
  }),
  statusWire({ corpus: 'cgt', documents: 7, massime: 0, passages: 30, skipped_without_text: 2, norme_pending: null, norme_resolved: null, norme_unresolved: null, note: 'Solo dopo la riforma.' }),
];

function setup(status: Handler, locale: 'sk' | 'en' | 'it' = 'en') {
  const env = stubGiuEnvironment({ status }, { locale });
  TestBed.configureTestingModule({ providers: [...giuProviders] });
  const fixture = TestBed.createComponent(StatusScreen);
  fixture.componentRef.setInput('context', env.context());
  return { env, fixture };
}

type Fixture = ComponentFixture<StatusScreen>;

async function settle(fixture: Fixture): Promise<void> {
  for (let i = 0; i < 4; i++) {
    await vi.waitFor(() => undefined);
    await Promise.resolve();
    fixture.detectChanges();
  }
}

const root = (fixture: Fixture): HTMLElement => fixture.nativeElement as HTMLElement;
const rows = (fixture: Fixture): HTMLElement[] => [...root(fixture).querySelectorAll<HTMLElement>('[data-testid="status-row"]')];

describe('StatusScreen', () => {
  it('should render one row per corpus with its counts, last ingest and note when the Tool returns three rows', async () => {
    const { env, fixture } = setup(threeRows);
    fixture.detectChanges();
    await settle(fixture);
    const items = rows(fixture);
    expect(items).toHaveLength(3);
    expect(items[0]?.textContent).toContain('Constitutional Court');
    expect(items[0]?.textContent).toContain('120');
    expect(items[0]?.textContent).toContain('300');
    expect(items[0]?.textContent).toContain('Constitutional Court, open data CC BY-SA 3.0');
    expect(items[1]?.textContent).toContain('Cassation');
    expect(items[1]?.textContent).toContain('2026-11-10');
    expect(items[1]?.textContent).toContain('only from 2021');
    expect(items[2]?.textContent).toContain('Tax courts');
    expect(callsOf(env, 'status')).toEqual([{}]);
  });

  it('should show the English note of each corpus and not the Italian Tool text when the locale is en', async () => {
    const { fixture } = setup(threeRows, 'en');
    fixture.detectChanges();
    await settle(fixture);
    const [cc, cass, cgt] = rows(fixture);
    expect(cc?.querySelector('.note')?.textContent).toContain('Constitutional Court, open data CC BY-SA 3.0');
    expect(cass?.querySelector('.note')?.textContent).toContain('only from 2021');
    expect(cgt?.querySelector('.note')?.textContent).toContain('only after the reform');
    for (const row of [cc, cass, cgt]) {
      expect(row?.querySelector('.note')?.textContent).not.toMatch(/Nota della|Solo dal|Solo dopo/);
    }
  });

  it('should show the Slovak note of each corpus and not the Italian Tool text when the locale is sk', async () => {
    const { fixture } = setup(threeRows, 'sk');
    fixture.detectChanges();
    await settle(fixture);
    const [cc, cass, cgt] = rows(fixture);
    expect(cc?.querySelector('.note')?.textContent).toContain('Ústavný súd, otvorené dáta CC BY-SA 3.0');
    expect(cass?.querySelector('.note')?.textContent).toContain('iba od roku 2021');
    expect(cgt?.querySelector('.note')?.textContent).toContain('iba po reforme');
    for (const row of [cc, cass, cgt]) {
      expect(row?.querySelector('.note')?.textContent).not.toMatch(/Nota della|Solo dal|Solo dopo/);
    }
  });

  it('should show the Italian note of each corpus when the locale is it', async () => {
    const { fixture } = setup(threeRows, 'it');
    fixture.detectChanges();
    await settle(fixture);
    const [cc, cass, cgt] = rows(fixture);
    expect(cc?.querySelector('.note')?.textContent).toContain('Corte costituzionale, open data CC BY-SA 3.0');
    expect(cass?.querySelector('.note')?.textContent).toContain('solo dal 2021');
    expect(cgt?.querySelector('.note')?.textContent).toContain('solo dopo la riforma');
  });

  it('should fall back to the Tool note when the corpus is not one of the three', async () => {
    const { fixture } = setup(() => [statusWire({ corpus: 'altro', note: 'Nota libera del Tool.' })], 'en');
    fixture.detectChanges();
    await settle(fixture);
    expect(rows(fixture)[0]?.querySelector('.note')?.textContent).toContain('Nota libera del Tool.');
  });

  it('should show the registry counts on the cc row and the skipped count on the cgt row when they are present', async () => {
    const { fixture } = setup(threeRows);
    fixture.detectChanges();
    await settle(fixture);
    const [cc, , cgt] = rows(fixture);
    expect(must(cc ?? root(fixture), '[data-testid="status-norme"]').textContent).toContain('5');
    expect(cc?.querySelector('[data-testid="status-skipped"]')).toBeNull();
    expect(must(cgt ?? root(fixture), '[data-testid="status-skipped"]').textContent).toContain('2');
    expect(cgt?.querySelector('[data-testid="status-norme"]')).toBeNull();
  });

  it('should show the warning badge only on rows with passages without embedding when the counts differ', async () => {
    const { fixture } = setup(threeRows);
    fixture.detectChanges();
    await settle(fixture);
    const [cc, cass, cgt] = rows(fixture);
    expect(cc?.querySelector('[data-testid="status-warning"]')).toBeNull();
    expect(cgt?.querySelector('[data-testid="status-warning"]')).toBeNull();
    const badge = must(cass ?? root(fixture), '[data-testid="status-warning"]');
    expect(badge.textContent).toContain('12');
    expect(badge.getAttribute('role')).toBe('status');
  });

  it('should call the Tool again and show the new rows when refresh is clicked', async () => {
    let call = 0;
    const { env, fixture } = setup(() => (++call === 1 ? [statusWire()] : threeRows()));
    fixture.detectChanges();
    await settle(fixture);
    expect(rows(fixture)).toHaveLength(1);
    must(root(fixture), '[data-testid="status-refresh"]').click();
    await settle(fixture);
    expect(callsOf(env, 'status')).toHaveLength(2);
    expect(rows(fixture)).toHaveLength(3);
  });

  it('should show the empty state when the Tool returns no rows', async () => {
    const { fixture } = setup(() => []);
    fixture.detectChanges();
    await settle(fixture);
    expect(rows(fixture)).toHaveLength(0);
    expect(must(root(fixture), '[data-testid="status-empty"]').textContent).toContain('Nothing has been ingested');
  });

  it('should show the error state and keep refresh available when the Tool fails', async () => {
    const { fixture } = setup(() => {
      throw new Error('boom');
    });
    fixture.detectChanges();
    await settle(fixture);
    expect(must(root(fixture), '[data-testid="status-error"]').textContent).toContain('could not be loaded');
    expect((must(root(fixture), '[data-testid="status-refresh"]') as HTMLButtonElement).disabled).toBe(false);
  });

  it('should show the licence footer in English even when there are no rows', async () => {
    const { fixture } = setup(() => []);
    fixture.detectChanges();
    await settle(fixture);
    const footer = must(root(fixture), '[data-testid="status-footer"]').textContent;
    expect(footer).toContain('CC BY-SA 3.0');
    expect(footer).toContain('internal use, no redistribution');
  });

  it('should show the licence footer in Slovak when the locale is sk', async () => {
    const { fixture } = setup(() => [], 'sk');
    fixture.detectChanges();
    await settle(fixture);
    const footer = must(root(fixture), '[data-testid="status-footer"]').textContent;
    expect(footer).toContain('CC BY-SA 3.0');
    expect(footer).toContain('interné použitie, bez ďalšieho šírenia');
  });

  it('should show the licence footer in Italian when the locale is it', async () => {
    const { fixture } = setup(() => [], 'it');
    fixture.detectChanges();
    await settle(fixture);
    const footer = must(root(fixture), '[data-testid="status-footer"]').textContent;
    expect(footer).toContain('CC BY-SA 3.0');
    expect(footer).toContain('uso interno, nessuna ridistribuzione');
    expect(must(root(fixture), '[data-testid="status-empty"]').textContent).toContain('Nessun dato');
  });
});
