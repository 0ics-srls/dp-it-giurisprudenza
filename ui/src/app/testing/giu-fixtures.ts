/** Wire rows (snake case, like the Tool SQL returns them) for the specs. */
export type WireRow = Record<string, unknown>;

export function listWire(over: WireRow = {}): WireRow {
  return {
    ecli: 'ECLI:IT:COST:2026:95',
    tipologia: 'O',
    anno: 2026,
    numero: 95,
    data_deposito: '2026-05-14',
    relatore: 'Mario Rossi',
    massime_count: 2,
    total: 3,
    ...over,
  };
}

export function ccHitWire(over: WireRow = {}): WireRow {
  return {
    ecli: 'ECLI:IT:COST:2017:180',
    tipologia: 'S',
    anno: 2017,
    numero: 180,
    data_deposito: '2017-07-20',
    source: 'massima',
    massima_numero: 3,
    titolo: 'Licenziamento illegittimo',
    headline: 'Il «licenziamento» senza giusta causa',
    snippet: 'Il licenziamento senza giusta causa e illegittimo.',
    source_url: 'https://www.cortecostituzionale.it/scheda-pronuncia/2017/180',
    position: 1,
    ...over,
  };
}

export function pronunciaWire(over: WireRow = {}): WireRow {
  return {
    ecli: 'ECLI:IT:COST:2026:95',
    anno: 2026,
    numero: 95,
    tipologia: 'O',
    presidente: 'Giovanni Amoroso',
    relatore: 'Mario Rossi',
    redattore: 'Mario Rossi',
    data_decisione: '2026-04-28',
    data_deposito: '2026-05-14',
    collegio: 'Collegio X',
    epigrafe: 'Epigrafe della decisione, iscritta al n. 173 del registro ordinanze 2025.',
    fatto: 'Ritenuto in fatto che il giudice rimettente.',
    diritto: 'Considerato in diritto che la questione e inammissibile.',
    testo: null,
    dispositivo: 'PER QUESTI MOTIVI LA CORTE dichiara inammissibile.',
    source_url: 'https://www.cortecostituzionale.it/scheda-pronuncia/2026/95',
    ...over,
  };
}

export function massimaWire(over: WireRow = {}): WireRow {
  return {
    ecli: 'ECLI:IT:COST:2026:95',
    numero: 1,
    titolo: 'Prima massima',
    testo: 'Testo della prima massima.',
    source_url: 'https://www.cortecostituzionale.it/scheda-pronuncia/2026/95',
    ...over,
  };
}

export function normaWire(over: WireRow = {}): WireRow {
  return {
    registro_tipo: 'ordinanze',
    registro_anno: 2025,
    registro_numero: 173,
    norma_urn: 'urn:nir:stato:legge:2022-12-29;197~art1',
    norma_descrizione: 'legge 29 dicembre 2022, n. 197',
    norma_articolo: '1',
    norma_comma: null,
    pending: true,
    resolved: true,
    ecli: 'ECLI:IT:COST:2026:95',
    anno: 2026,
    numero: 95,
    tipologia: 'O',
    data_deposito: '2026-05-14',
    source_url: 'https://www.cortecostituzionale.it/scheda-pronuncia/2026/95',
    unresolved_registri: 1,
    ...over,
  };
}

export function cassWire(over: WireRow = {}): WireRow {
  return {
    source_id: 'snciv2025000123O',
    ecli: 'ECLI:IT:CASS:2025:123',
    kind: 'snciv',
    sezione: '5',
    anno: 2025,
    num_dec: 123,
    data_decisione: '2025-01-15',
    materia: 'TRIBUTI',
    tipo_prov: 'Ordinanza',
    headline: null,
    snippet: 'Estratto della ordinanza di cassazione.',
    source_url: 'https://www.italgiure.giustizia.it/sncass/#/ricerca?id=snciv2025000123O',
    position: 1,
    ...over,
  };
}

export function cgtWire(over: WireRow = {}): WireRow {
  return {
    id: '3f2b8c1e-6d3a-4a52-9f0e-1c2d3e4f5a6b',
    tipo: 'Sentenza',
    grado: 2,
    luogo: 'Campania',
    sezione: '2',
    anno: 2024,
    numero: 7355,
    data: '2024-12-31',
    estremi: 'Sentenza del 31/12/2024 n. 7355 - Corte di giustizia tributaria di secondo grado della Campania - Sezione/Collegio 2',
    headline: null,
    snippet: 'Estratto della sentenza tributaria.',
    source_url: 'https://def.finanze.it/DocTribFrontend/getGiurisprudenzaDetail.do?id=3f2b8c1e-6d3a-4a52-9f0e-1c2d3e4f5a6b',
    position: 1,
    ...over,
  };
}

export function statusWire(over: WireRow = {}): WireRow {
  return {
    corpus: 'cc',
    documents: 120,
    massime: 300,
    passages: 900,
    passages_without_embedding: 0,
    last_ingested_at: null,
    norme_pending: 5,
    norme_resolved: 2,
    norme_unresolved: 3,
    skipped_without_text: null,
    note: 'Nota della Corte costituzionale.',
    ...over,
  };
}
