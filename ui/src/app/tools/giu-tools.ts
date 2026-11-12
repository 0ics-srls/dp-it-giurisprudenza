import { Injectable } from '@angular/core';
import { injectPackageContext } from '@olx/package-ui-sdk';
import {
  DATE_KEYS,
  NUMBER_KEYS,
  type CassazioneHit,
  type CcHit,
  type CgtHit,
  type Massima,
  type NormaRow,
  type Pronuncia,
  type PronunciaListRow,
  type StatusRow,
} from './giu-dto';
import { GiuTool, TOOL_INPUT_KEYS } from './giu-tool';

/** A Tool call failed; carries the Tool name and the code of the rejection when it had one. */
export class GiuToolError extends Error {
  constructor(
    readonly tool: GiuTool,
    readonly code: string | null,
    message: string,
  ) {
    super(message);
    this.name = 'GiuToolError';
  }
}

type Wire = Record<string, unknown>;

const camel = (key: string): string => key.replace(/_([a-z0-9])/g, (_, c: string) => c.toUpperCase());
const snake = (key: string): string => key.replace(/[A-Z]/g, (c) => `_${c.toLowerCase()}`);

function toDate(value: unknown): Date | null {
  if (value === null || value === undefined || value === '') {
    return null;
  }
  const date = new Date(typeof value === 'string' ? value : NaN);
  return Number.isNaN(date.getTime()) ? null : date;
}

function toNumber(value: unknown): unknown {
  if (typeof value === 'string' && value.trim() !== '' && !Number.isNaN(Number(value))) {
    return Number(value);
  }
  return value;
}

function mapRow(row: Wire): Wire {
  const mapped: Wire = {};
  for (const [key, value] of Object.entries(row)) {
    const name = camel(key);
    mapped[name] = DATE_KEYS.includes(name) ? toDate(value) : NUMBER_KEYS.includes(name) ? toNumber(value) : value;
  }
  return mapped;
}

/** snake case input from camelCase arguments; undefined arguments are dropped, only keys of the Tool are sent. */
function buildInput(tool: GiuTool, args: Readonly<Record<string, unknown>>): Wire {
  const allowed = TOOL_INPUT_KEYS[tool];
  const input: Wire = {};
  for (const [key, value] of Object.entries(args)) {
    const wire = snake(key);
    if (value !== undefined && allowed.includes(wire)) {
      input[wire] = value;
    }
  }
  return input;
}

function unwrap(result: unknown): readonly Wire[] {
  if (Array.isArray(result)) {
    return result as Wire[];
  }
  if (typeof result === 'object' && result !== null && Array.isArray((result as { data?: unknown }).data)) {
    return (result as { data: Wire[] }).data;
  }
  return [];
}

function codeOf(error: unknown): string | null {
  const code = typeof error === 'object' && error !== null ? (error as { code?: unknown }).code : undefined;
  return typeof code === 'string' ? code : null;
}

export interface CcSearchArgs {
  readonly query?: string | undefined;
  readonly tipologia?: string | undefined;
  readonly annoFrom?: number | undefined;
  readonly annoTo?: number | undefined;
  readonly k?: number | undefined;
}

export interface CassazioneSearchArgs {
  readonly query?: string | undefined;
  readonly kind?: string | undefined;
  readonly annoFrom?: number | undefined;
  readonly annoTo?: number | undefined;
  readonly sezione?: string | undefined;
  readonly materia?: string | undefined;
}

export interface CgtSearchArgs {
  readonly query?: string | undefined;
  readonly grado?: number | undefined;
  readonly luogo?: string | undefined;
  readonly annoFrom?: number | undefined;
  readonly annoTo?: number | undefined;
}

/** The only place the Screens call Tools: camelCase in, camelCase rows out. */
@Injectable()
export class GiuTools {
  private readonly context = injectPackageContext();

  private async call(tool: GiuTool, args: Readonly<Record<string, unknown>> = {}): Promise<readonly Wire[]> {
    try {
      return unwrap(await this.context().tools.call<unknown>(tool, buildInput(tool, args)));
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      throw new GiuToolError(tool, codeOf(error), message);
    }
  }

  private async rows<T>(tool: GiuTool, args: Readonly<Record<string, unknown>> = {}): Promise<readonly T[]> {
    return (await this.call(tool, args)).map((row) => mapRow(row) as T);
  }

  listPronunce(a: { anno?: number | undefined; tipologia?: string | undefined; q?: string | undefined; limit: number; offset: number }): Promise<readonly PronunciaListRow[]> {
    return this.rows(GiuTool.PronunceList, a);
  }

  searchCc(a: CcSearchArgs): Promise<readonly CcHit[]> {
    return this.rows(GiuTool.Search, { ...a });
  }

  /** One decision, null when the ECLI is unknown. */
  async pronuncia(ecli: string): Promise<Pronuncia | null> {
    const [row] = await this.rows<Pronuncia>(GiuTool.Pronuncia, { ecli });
    return row ?? null;
  }

  massime(ecli: string): Promise<readonly Massima[]> {
    return this.rows(GiuTool.Massime, { ecli });
  }

  sentenzeSuNorma(normaUrn: string): Promise<readonly NormaRow[]> {
    return this.rows(GiuTool.SentenzeSuNorma, { normaUrn });
  }

  searchCassazione(a: CassazioneSearchArgs): Promise<readonly CassazioneHit[]> {
    return this.rows(GiuTool.CassazioneSearch, { ...a });
  }

  /** Every match of an ECLI (it is not an identity) or the one sentence of a source id. */
  cassazioneSentenza(a: { ecli?: string | undefined; sourceId?: string | undefined }): Promise<readonly CassazioneHit[]> {
    return this.rows(GiuTool.CassazioneSentenza, a);
  }

  searchCgt(a: CgtSearchArgs): Promise<readonly CgtHit[]> {
    return this.rows(GiuTool.CgtSearch, { ...a });
  }

  async cgtPronuncia(id: string): Promise<CgtHit | null> {
    const [row] = await this.rows<CgtHit>(GiuTool.CgtPronuncia, { id });
    return row ?? null;
  }

  status(): Promise<readonly StatusRow[]> {
    return this.rows(GiuTool.Status);
  }
}
