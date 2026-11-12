import { TestBed, type ComponentFixture } from '@angular/core/testing';
import { must } from '../../testing/dom';
import { cassWire, cgtWire, massimaWire, normaWire, pronunciaWire } from '../../testing/giu-fixtures';
import { callsOf, stubGiuEnvironment } from '../../testing/stub-giu-tools';
import { giuProviders } from '../../providers';
import { DecisionScreen } from './decision.screen';

type Handler = (input: object) => unknown;

interface Handlers {
  readonly pronuncia?: Handler;
  readonly massime?: Handler;
  readonly norma?: Handler;
  readonly cass?: Handler;
  readonly cgt?: Handler;
}

const ECLI = 'ECLI:IT:COST:2026:95';

function setup(subPath: string, handlers: Handlers = {}, overrides: Parameters<typeof stubGiuEnvironment>[1] = {}) {
  const env = stubGiuEnvironment(
    {
      pronuncia: handlers.pronuncia ?? (() => [pronunciaWire()]),
      massime: handlers.massime ?? (() => [massimaWire({ numero: 1 }), massimaWire({ numero: 2, titolo: 'Seconda massima', testo: 'Testo della seconda massima.' })]),
      sentenze_su_norma: handlers.norma ?? (() => []),
      cassazione_sentenza: handlers.cass ?? (() => [cassWire()]),
      cgt_pronuncia: handlers.cgt ?? (() => [cgtWire()]),
    },
    { locale: 'en', subPath, ...overrides },
  );
  TestBed.configureTestingModule({ providers: [...giuProviders] });
  const fixture = TestBed.createComponent(DecisionScreen);
  fixture.componentRef.setInput('context', env.context());
  return { env, fixture };
}

type Fixture = ComponentFixture<DecisionScreen>;

async function settle(fixture: Fixture): Promise<void> {
  for (let i = 0; i < 4; i++) {
    await vi.waitFor(() => undefined);
    await Promise.resolve();
    fixture.detectChanges();
  }
}

const root = (fixture: Fixture): HTMLElement => fixture.nativeElement as HTMLElement;
const el = (fixture: Fixture, id: string): HTMLElement => must(root(fixture), `[data-testid="${id}"]`);
const all = (fixture: Fixture, id: string): HTMLElement[] => [...root(fixture).querySelectorAll<HTMLElement>(`[data-testid="${id}"]`)];

async function loaded(subPath: string, handlers: Handlers = {}, overrides: Parameters<typeof stubGiuEnvironment>[1] = {}) {
  const made = setup(subPath, handlers, overrides);
  made.fixture.detectChanges();
  await settle(made.fixture);
  return made;
}

describe('DecisionScreen', () => {
  describe('Corte costituzionale', () => {
    it('should load pronuncia and massime once each and render the header, sections and massime in order when the key is cc', async () => {
      const { env, fixture } = await loaded(`cc~${ECLI}`);
      expect(callsOf(env, 'pronuncia')).toEqual([{ ecli: ECLI }]);
      expect(callsOf(env, 'massime')).toEqual([{ ecli: ECLI }]);
      const header = el(fixture, 'decision-header').textContent;
      for (const text of [ECLI, 'Giovanni Amoroso', 'Mario Rossi', '2026-05-14', '2026-04-28']) {
        expect(header, text).toContain(text);
      }
      expect(el(fixture, 'section-epigrafe').textContent).toContain('iscritta al n. 173 del registro ordinanze 2025');
      expect(el(fixture, 'section-fatto').textContent).toContain('Ritenuto in fatto');
      expect(el(fixture, 'section-diritto').textContent).toContain('Considerato in diritto');
      expect(el(fixture, 'section-dispositivo').textContent).toContain('PER QUESTI MOTIVI');
      expect(all(fixture, 'section-testo')).toHaveLength(0);
      const massime = all(fixture, 'massima-row');
      expect(massime).toHaveLength(2);
      expect(massime[0]?.textContent).toContain('Prima massima');
      expect(massime[1]?.textContent).toContain('Seconda massima');
      expect(massime[1]?.textContent).toContain('Testo della seconda massima.');
    });

    it('should collapse and expand a section when its toggle is clicked', async () => {
      const { fixture } = await loaded(`cc~${ECLI}`);
      expect(all(fixture, 'section-body-fatto')).toHaveLength(1);
      el(fixture, 'section-toggle-fatto').click();
      await settle(fixture);
      expect(all(fixture, 'section-body-fatto')).toHaveLength(0);
      el(fixture, 'section-toggle-fatto').click();
      await settle(fixture);
      expect(all(fixture, 'section-body-fatto')).toHaveLength(1);
    });

    it('should show the Court link with safe attributes and the attribution line when the decision is shown', async () => {
      const { fixture } = await loaded(`cc~${ECLI}`);
      const link = el(fixture, 'decision-source-link');
      expect(link.getAttribute('href')).toBe('https://www.cortecostituzionale.it/scheda-pronuncia/2026/95');
      expect(link.getAttribute('target')).toBe('_blank');
      expect(link.getAttribute('rel')).toBe('noopener noreferrer');
      expect(el(fixture, 'decision-attribution').textContent).toContain('Corte costituzionale, dati.cortecostituzionale.it, CC BY-SA 3.0');
    });

    it('should render a section text as text and not as html when the text holds markup', async () => {
      const { fixture } = await loaded(`cc~${ECLI}`, { pronuncia: () => [pronunciaWire({ fatto: 'Fatto <script>window.__y = 1</script> <b>grassetto</b>' })] });
      const body = el(fixture, 'section-body-fatto');
      expect(body.querySelector('script')).toBeNull();
      expect(body.querySelector('b')).toBeNull();
      expect(body.textContent).toContain('<script>window.__y = 1</script>');
    });

    it('should show no link when the source url is not https', async () => {
      const { fixture } = await loaded(`cc~${ECLI}`, { pronuncia: () => [pronunciaWire({ source_url: 'javascript:alert(1)' })] });
      expect(all(fixture, 'decision-source-link')).toHaveLength(0);
    });

    it('should show the not-found state when the ecli is unknown', async () => {
      const { fixture } = await loaded('cc~ECLI:IT:COST:1900:1', { pronuncia: () => [], massime: () => [] });
      expect(el(fixture, 'decision-notfound').textContent).toContain('not found');
      expect(all(fixture, 'decision-header')).toHaveLength(0);
    });

    it('should show the error state when the Tool fails', async () => {
      const { fixture } = await loaded(`cc~${ECLI}`, {
        pronuncia: () => {
          throw new Error('boom');
        },
      });
      expect(el(fixture, 'decision-error').textContent).toContain('could not be loaded');
    });

    it('should say there are no massime when the decision has none', async () => {
      const { fixture } = await loaded(`cc~${ECLI}`, { massime: () => [] });
      expect(all(fixture, 'massima-row')).toHaveLength(0);
      expect(el(fixture, 'massime-empty').textContent).toContain('No massime');
    });

    it('should navigate back to the corpus list when back is clicked', async () => {
      const navigateScreen = vi.fn();
      const { fixture } = await loaded(`cc~${ECLI}`, {}, { navigateScreen });
      el(fixture, 'decision-back').click();
      expect(navigateScreen).toHaveBeenCalledExactlyOnceWith('corpus');
    });
  });

  describe('norma box', () => {
    it('should call sentenze_su_norma with the typed urn and show resolved and unresolved counts and the absence note', async () => {
      const urn = 'urn:nir:stato:legge:2022-12-29;197~art1';
      const rows = [normaWire(), normaWire({ registro_numero: 71, registro_anno: 2026, resolved: false, ecli: null, anno: null, numero: null, tipologia: null, data_deposito: null, source_url: null, unresolved_registri: 1 })];
      const { env, fixture } = await loaded(`cc~${ECLI}`, { norma: () => rows });
      const input = el(fixture, 'norma-input') as HTMLInputElement;
      input.value = urn;
      input.dispatchEvent(new Event('input'));
      el(fixture, 'norma-submit').click();
      await settle(fixture);
      expect(callsOf(env, 'sentenze_su_norma')).toEqual([{ norma_urn: urn }]);
      const items = all(fixture, 'norma-row');
      expect(items).toHaveLength(2);
      expect(items[0]?.querySelector('[data-testid="norma-state"]')?.textContent).toContain('Resolved');
      expect(items[1]?.querySelector('[data-testid="norma-state"]')?.textContent).toContain('Unresolved');
      expect(el(fixture, 'norma-resolved-count').textContent).toContain('1');
      expect(el(fixture, 'norma-unresolved-count').textContent).toContain('1');
      expect(el(fixture, 'norma-note').textContent).toContain('not proof');
    });

    it('should open the resolved decision when a resolved row is clicked', async () => {
      const navigateScreen = vi.fn();
      const { fixture } = await loaded(`cc~${ECLI}`, { norma: () => [normaWire({ ecli: 'ECLI:IT:COST:2026:104' })] }, { navigateScreen });
      const input = el(fixture, 'norma-input') as HTMLInputElement;
      input.value = 'urn:nir:stato:legge:2022-12-29;197';
      input.dispatchEvent(new Event('input'));
      el(fixture, 'norma-submit').click();
      await settle(fixture);
      el(fixture, 'norma-open').click();
      expect(navigateScreen).toHaveBeenCalledExactlyOnceWith('decision', 'cc~ECLI:IT:COST:2026:104');
    });

    it('should not call the Tool and show a hint when the typed text is not a urn', async () => {
      const { env, fixture } = await loaded(`cc~${ECLI}`);
      const input = el(fixture, 'norma-input') as HTMLInputElement;
      input.value = 'legge 197/2022';
      input.dispatchEvent(new Event('input'));
      el(fixture, 'norma-submit').click();
      await settle(fixture);
      expect(callsOf(env, 'sentenze_su_norma')).toEqual([]);
      expect(el(fixture, 'norma-invalid').textContent).toContain('urn:nir:');
    });

    it('should say that nothing was found, without claiming absence, when the registry has no row', async () => {
      const { fixture } = await loaded(`cc~${ECLI}`);
      const input = el(fixture, 'norma-input') as HTMLInputElement;
      input.value = 'urn:nir:stato:legge:2022-12-29;197';
      input.dispatchEvent(new Event('input'));
      el(fixture, 'norma-submit').click();
      await settle(fixture);
      expect(all(fixture, 'norma-row')).toHaveLength(0);
      expect(el(fixture, 'norma-empty').textContent).toContain('No registry rows');
      expect(el(fixture, 'norma-note').textContent).toContain('not proof');
    });
  });

  describe('Cassazione', () => {
    it('should call cassazione_sentenza with the source id and show extremes, snippet and link only when the key is cass~source_id', async () => {
      const { env, fixture } = await loaded('cass~snciv2025000123O');
      expect(callsOf(env, 'cassazione_sentenza')).toEqual([{ source_id: 'snciv2025000123O' }]);
      expect(callsOf(env, 'pronuncia')).toEqual([]);
      expect(callsOf(env, 'massime')).toEqual([]);
      const row = el(fixture, 'detail-row');
      for (const text of ['ECLI:IT:CASS:2025:123', 'TRIBUTI', 'Estratto della ordinanza di cassazione.']) {
        expect(row.textContent, text).toContain(text);
      }
      expect(el(fixture, 'detail-notice').textContent).toContain('never the full text');
      const link = el(fixture, 'detail-source-link');
      expect(link.getAttribute('href')).toContain('https://www.italgiure.giustizia.it/');
      expect(link.getAttribute('target')).toBe('_blank');
      expect(link.getAttribute('rel')).toBe('noopener noreferrer');
      expect(all(fixture, 'section-body-fatto')).toHaveLength(0);
    });

    it('should call it with the ecli and render both rows when the key is cass~ECLI and two sentences share the ecli', async () => {
      const { env, fixture } = await loaded('cass~ECLI:IT:CASS:2021:33380', {
        cass: () => [cassWire({ source_id: 'snciv2021033380A', snippet: 'Prima sentenza.' }), cassWire({ source_id: 'snpen2021033380B', kind: 'snpen', snippet: 'Seconda sentenza.' })],
      });
      expect(callsOf(env, 'cassazione_sentenza')).toEqual([{ ecli: 'ECLI:IT:CASS:2021:33380' }]);
      const rows = all(fixture, 'detail-row');
      expect(rows).toHaveLength(2);
      expect(rows[0]?.textContent).toContain('Prima sentenza.');
      expect(rows[1]?.textContent).toContain('Seconda sentenza.');
    });

    it('should show the snippet unaltered when it is long, and no other text of the sentence', async () => {
      const snippet = 'Estratto '.repeat(250).trim();
      const { fixture } = await loaded('cass~snciv2025000123O', { cass: () => [cassWire({ snippet, text_anon: 'TESTO INTEGRALE RISERVATO', text_raw_original: 'ORIGINALE' })] });
      expect(el(fixture, 'detail-snippet').textContent.trim()).toBe(snippet);
      expect(root(fixture).textContent).not.toContain('TESTO INTEGRALE RISERVATO');
      expect(root(fixture).textContent).not.toContain('ORIGINALE');
    });

    it('should render no link when the source url is not https', async () => {
      const { fixture } = await loaded('cass~snciv2025000123O', { cass: () => [cassWire({ source_url: 'http://www.italgiure.giustizia.it/x' })] });
      expect(all(fixture, 'detail-source-link')).toHaveLength(0);
    });

    it('should show the not-found state when no sentence matches', async () => {
      const { fixture } = await loaded('cass~snciv0', { cass: () => [] });
      expect(el(fixture, 'decision-notfound').textContent).toContain('not found');
    });
  });

  describe('Tributaria', () => {
    it('should call cgt_pronuncia with the id and show estremi, snippet, link and the notice', async () => {
      const id = '3f2b8c1e-6d3a-4a52-9f0e-1c2d3e4f5a6b';
      const { env, fixture } = await loaded(`cgt~${id}`);
      expect(callsOf(env, 'cgt_pronuncia')).toEqual([{ id }]);
      expect(el(fixture, 'detail-estremi').textContent).toContain('Sentenza del 31/12/2024 n. 7355');
      expect(el(fixture, 'detail-snippet').textContent).toContain('Estratto della sentenza tributaria.');
      expect(el(fixture, 'detail-notice').textContent).toContain('never the full text');
      const link = el(fixture, 'detail-source-link');
      expect(link.getAttribute('href')).toContain('https://def.finanze.it/');
      expect(link.getAttribute('rel')).toBe('noopener noreferrer');
    });

    it('should show the not-found state when the id is unknown', async () => {
      const { fixture } = await loaded('cgt~3f2b8c1e-6d3a-4a52-9f0e-1c2d3e4f5a6b', { cgt: () => [] });
      expect(el(fixture, 'decision-notfound').textContent).toContain('not found');
    });
  });

  describe('key', () => {
    it('should show a hint and call no Tool when the key is missing or unknown', async () => {
      for (const subPath of ['', 'cc~', 'xx~1', 'garbage']) {
        TestBed.resetTestingModule();
        const { env, fixture } = await loaded(subPath);
        expect(el(fixture, 'decision-missing').textContent).toContain('Open a decision');
        expect(env.calls).toEqual([]);
      }
    });

    it('should take the slash of an id from %2F when the key was built by the list', async () => {
      const { env } = await loaded('cass~snciv2025%2F123');
      expect(callsOf(env, 'cassazione_sentenza')).toEqual([{ source_id: 'snciv2025/123' }]);
    });

    it('should render Slovak and Italian texts when the locale changes', async () => {
      const sk = await loaded('', {}, { locale: 'sk' });
      expect(el(sk.fixture, 'decision-missing').textContent).toContain('Otvorte rozhodnutie');
      TestBed.resetTestingModule();
      const it = await loaded('', {}, { locale: 'it' });
      expect(el(it.fixture, 'decision-missing').textContent).toContain('Aprire una decisione');
    });
  });
});
