/** One decision of `pronunce_list`; `total` is the number of matching decisions, repeated on every row. */
export interface PronunciaListRow {
  readonly ecli: string;
  readonly tipologia: string;
  readonly anno: number;
  readonly numero: number;
  readonly dataDeposito: Date | null;
  readonly relatore: string | null;
  readonly massimeCount: number;
  readonly total: number;
}

/** One hit of `search` (a massima or a decision of the Corte costituzionale). */
export interface CcHit {
  readonly ecli: string;
  readonly tipologia: string;
  readonly anno: number;
  readonly numero: number;
  readonly dataDeposito: Date | null;
  readonly source: 'massima' | 'pronuncia';
  readonly massimaNumero: number | null;
  readonly titolo: string | null;
  readonly headline: string | null;
  readonly snippet: string | null;
  readonly sourceUrl: string | null;
  readonly position: number;
}

/** One decision of `pronuncia` with every section (open data). */
export interface Pronuncia {
  readonly ecli: string;
  readonly anno: number;
  readonly numero: number;
  readonly tipologia: string;
  readonly presidente: string | null;
  readonly relatore: string | null;
  readonly redattore: string | null;
  readonly dataDecisione: Date | null;
  readonly dataDeposito: Date | null;
  readonly collegio: string | null;
  readonly epigrafe: string | null;
  readonly fatto: string | null;
  readonly diritto: string | null;
  readonly testo: string | null;
  readonly dispositivo: string | null;
  readonly sourceUrl: string | null;
}

export interface Massima {
  readonly ecli: string;
  readonly numero: number;
  readonly titolo: string | null;
  readonly testo: string;
  readonly sourceUrl: string | null;
}

/** One registry row of `sentenze_su_norma`; `unresolvedRegistri` is repeated on every row. */
export interface NormaRow {
  readonly registroTipo: string;
  readonly registroAnno: number;
  readonly registroNumero: number;
  readonly normaUrn: string;
  readonly normaDescrizione: string | null;
  readonly normaArticolo: string | null;
  readonly normaComma: string | null;
  readonly pending: boolean;
  readonly resolved: boolean;
  readonly ecli: string | null;
  readonly anno: number | null;
  readonly numero: number | null;
  readonly tipologia: string | null;
  readonly dataDeposito: Date | null;
  readonly sourceUrl: string | null;
  readonly unresolvedRegistri: number;
}

/** Extremes + snippet of a Cassazione sentence (`cassazione_search`, `cassazione_sentenza`); never the full text. */
export interface CassazioneHit {
  readonly sourceId: string;
  readonly ecli: string | null;
  readonly kind: string;
  readonly sezione: string | null;
  readonly anno: number;
  readonly numDec: number | null;
  readonly dataDecisione: Date | null;
  readonly materia: string | null;
  readonly tipoProv: string | null;
  readonly headline: string | null;
  readonly snippet: string | null;
  readonly sourceUrl: string | null;
}

/** Extremes + snippet of a CGT decision (`cgt_search`, `cgt_pronuncia`); never the full text. */
export interface CgtHit {
  readonly id: string;
  readonly tipo: string | null;
  readonly grado: number | null;
  readonly luogo: string | null;
  readonly sezione: string | null;
  readonly anno: number | null;
  readonly numero: number | null;
  readonly data: Date | null;
  readonly estremi: string | null;
  readonly headline: string | null;
  readonly snippet: string | null;
  readonly sourceUrl: string | null;
}

/** One corpus of `status`. */
export interface StatusRow {
  readonly corpus: string;
  readonly documents: number;
  readonly massime: number;
  readonly passages: number;
  readonly passagesWithoutEmbedding: number;
  readonly lastIngestedAt: Date | null;
  readonly normePending: number | null;
  readonly normeResolved: number | null;
  readonly normeUnresolved: number | null;
  readonly skippedWithoutText: number | null;
  readonly note: string | null;
}

/** Wire names (camelCase) of the date members; the number members arrive as bigint text from some hosts and are coerced. */
export const DATE_KEYS: readonly string[] = ['dataDeposito', 'dataDecisione', 'data', 'lastIngestedAt'];
export const NUMBER_KEYS: readonly string[] = [
  'anno', 'numero', 'total', 'massimeCount', 'massimaNumero', 'position', 'registroAnno', 'registroNumero', 'unresolvedRegistri', 'numDec', 'grado',
  'documents', 'massime', 'passages', 'passagesWithoutEmbedding', 'normePending', 'normeResolved', 'normeUnresolved', 'skippedWithoutText',
];
