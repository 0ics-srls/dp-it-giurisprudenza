import { computed, effect, inject, Injectable, signal, untracked } from '@angular/core';
import { injectPackageContext } from '@olx/package-ui-sdk';
import { decisionKey, parseDecisionKey } from '../../shared/decision-key';
import { httpsUrl } from '../../shared/safe-url';
import { textParts, type TextPart } from '../../shared/text-parts';
import type { CassazioneHit, CgtHit, Massima, NormaRow, Pronuncia } from '../../tools/giu-dto';
import { GiuTools } from '../../tools/giu-tools';

export type LoadState = 'idle' | 'loading' | 'ready' | 'notfound' | 'error';
export type NormaState = 'idle' | 'loading' | 'done' | 'invalid' | 'error';

export type SectionName = 'epigrafe' | 'fatto' | 'diritto' | 'testo' | 'dispositivo';
const SECTIONS: readonly SectionName[] = ['epigrafe', 'fatto', 'diritto', 'testo', 'dispositivo'];

export interface Section {
  readonly name: SectionName;
  readonly text: string;
}

export interface CassDetail {
  readonly hit: CassazioneHit;
  readonly snippet: readonly TextPart[];
  readonly link: string;
}

export interface CgtDetail {
  readonly hit: CgtHit;
  readonly snippet: readonly TextPart[];
  readonly link: string;
}

const NORMA_PREFIX = 'urn:nir:';

/** The detail Screen: one decision named by the route key, loaded when the key changes (an effect, never in the constructor, P78-30). */
@Injectable()
export class DecisionStore {
  private readonly tools = inject(GiuTools);
  private readonly context = injectPackageContext();

  readonly key = computed(() => parseDecisionKey(this.context().subPath));
  readonly state = signal<LoadState>('idle');
  readonly errorDetail = signal('');

  readonly pronuncia = signal<Pronuncia | null>(null);
  readonly massime = signal<readonly Massima[]>([]);
  readonly massimeError = signal(false);
  readonly collapsed = signal<readonly SectionName[]>([]);
  readonly sections = computed<readonly Section[]>(() => {
    const decision = this.pronuncia();
    if (decision === null) {
      return [];
    }
    return SECTIONS.map((name) => ({ name, text: decision[name] ?? '' })).filter((section) => section.text.trim() !== '');
  });
  readonly sourceLink = computed(() => httpsUrl(this.pronuncia()?.sourceUrl));

  readonly cass = signal<readonly CassDetail[]>([]);
  readonly cgt = signal<CgtDetail | null>(null);

  readonly normaText = signal('');
  readonly normaState = signal<NormaState>('idle');
  readonly normaRows = signal<readonly NormaRow[]>([]);
  readonly normaResolved = computed(() => this.normaRows().filter((row) => row.resolved).length);
  readonly normaUnresolved = computed(() => this.normaRows()[0]?.unresolvedRegistri ?? 0);

  private request = 0;

  constructor() {
    effect(() => {
      const key = this.key();
      untracked(() => void this.load(key));
    });
  }

  back(): void {
    this.context().navigateScreen('corpus');
  }

  toggle(name: SectionName): void {
    this.collapsed.update((list) => (list.includes(name) ? list.filter((item) => item !== name) : [...list, name]));
  }

  setNorma(text: string): void {
    this.normaText.set(text);
  }

  async searchNorma(): Promise<void> {
    const urn = this.normaText().trim();
    if (!urn.startsWith(NORMA_PREFIX)) {
      this.normaState.set('invalid');
      this.normaRows.set([]);
      return;
    }
    this.normaState.set('loading');
    try {
      this.normaRows.set(await this.tools.sentenzeSuNorma(urn));
      this.normaState.set('done');
    } catch {
      this.normaRows.set([]);
      this.normaState.set('error');
    }
  }

  openDecision(ecli: string): void {
    this.context().navigateScreen('decision', decisionKey('cc', ecli));
  }

  private reset(): void {
    this.errorDetail.set('');
    this.pronuncia.set(null);
    this.massime.set([]);
    this.massimeError.set(false);
    this.collapsed.set([]);
    this.cass.set([]);
    this.cgt.set(null);
    this.normaText.set('');
    this.normaState.set('idle');
    this.normaRows.set([]);
  }

  private async load(key: ReturnType<DecisionStore['key']>): Promise<void> {
    const request = ++this.request;
    this.reset();
    if (key === null) {
      this.state.set('idle');
      return;
    }
    this.state.set('loading');
    try {
      if (key.kind === 'cc') {
        const [decision, massime] = await Promise.all([
          this.tools.pronuncia(key.id),
          this.tools.massime(key.id).catch(() => null),
        ]);
        if (request !== this.request) {
          return;
        }
        this.pronuncia.set(decision);
        this.massime.set(massime ?? []);
        this.massimeError.set(massime === null);
        this.state.set(decision === null ? 'notfound' : 'ready');
      } else if (key.kind === 'cass') {
        const hits = await this.tools.cassazioneSentenza(key.id.startsWith('ECLI:') ? { ecli: key.id } : { sourceId: key.id });
        if (request !== this.request) {
          return;
        }
        this.cass.set(hits.map((hit) => ({ hit, snippet: textParts(hit.snippet), link: httpsUrl(hit.sourceUrl) })));
        this.state.set(hits.length === 0 ? 'notfound' : 'ready');
      } else {
        const hit = await this.tools.cgtPronuncia(key.id);
        if (request !== this.request) {
          return;
        }
        this.cgt.set(hit === null ? null : { hit, snippet: textParts(hit.snippet), link: httpsUrl(hit.sourceUrl) });
        this.state.set(hit === null ? 'notfound' : 'ready');
      }
    } catch (error) {
      if (request !== this.request) {
        return;
      }
      this.errorDetail.set(error instanceof Error ? error.message : String(error));
      this.state.set('error');
    }
  }
}
