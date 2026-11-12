SELECT '# Guida ricerca e navigazione — giurisprudenza italiana

## Cosa c''è
Tre corpora separati, ciascuno con i suoi strumenti (prefisso `it-giurisprudenza_`):
- Corte costituzionale: sentenze (S) e ordinanze (O), con le massime e i registri delle norme impugnate. Dati aperti della Corte (CC BY-SA 3.0: citare la fonte, i derivati restano CC BY-SA). Testo integrale disponibile.
- Corte di cassazione (ItalGiure, civile `snciv` e penale `snpen`): dal 2021 in poi, solo sentenze con testo.
- Corti di giustizia tributaria (MEF DocTrib, primo e secondo grado): solo la giustizia tributaria dopo la riforma.
Questo manuale è `it-giurisprudenza_guide`. Per i conteggi reali e i limiti aggiornati usa `it-giurisprudenza_status`.

## Postura legale (importante)
Per Cassazione e Corti tributarie la banca dati non è open data: gli strumenti restituiscono gli estremi, un breve estratto (evidenziato con « » oppure un passaggio di al massimo 1500 caratteri) e il link alla fonte. Non restituiscono mai il testo integrale: per leggerlo apri `source_url`. Il testo originale non anonimizzato non viene mai servito. Per la Corte costituzionale invece `it-giurisprudenza_pronuncia` restituisce la decisione completa.

## Corte costituzionale
Anatomia ECLI: `ECLI:IT:COST:2001:1` = Corte costituzionale, anno 2001, pronuncia n. 1.
- `it-giurisprudenza_search`: ricerca ibrida (lessicale + semantica) su pronunce e massime. Parametro `mode`: hybrid|lexical|semantic (default hybrid). Filtri: `tipologia` (S=sentenza, O=ordinanza), `anno_from`/`anno_to`, `relatore` (sottostringa), `deposito_from`/`deposito_to` (yyyy-MM-dd). `k` 1..50 (default 10). Ogni hit ha `source` = `massima` o `pronuncia`, l''ECLI, `headline` (solo se c''è un riscontro lessicale), `snippet` e `source_url`; l''ordine è di rilevanza, senza punteggio numerico.
- `it-giurisprudenza_pronuncia` (ecli): la decisione completa (testata, epigrafe, fatto, diritto, testo, dispositivo).
- `it-giurisprudenza_massime` (ecli): le massime della decisione, in ordine di numero. Nessuna riga = decisione sconosciuta oppure senza massime.
- `it-giurisprudenza_pronunce_list`: elenco paginato, dalla più recente.
- `it-giurisprudenza_sentenze_su_norma` (norma_urn, livello atto o articolo): le questioni di legittimità note su una norma. Il confronto è quello storico: lo stesso URN, l''atto, oppure qualsiasi articolo dello stesso atto (`norma_articolo` distingue). `resolved` dice se la decisione è collegata e caricata; `unresolved_registri` conta le questioni non ancora collegate a una decisione. I registri elencano cause PENDENTI e il collegamento passa dal numero di registro citato nell''epigrafe: l''assenza di risultati NON prova che non esistano pronunce.

## Corte di cassazione
- `it-giurisprudenza_cassazione_search`: stessa sintassi di ricerca (websearch: "frase esatta", parola OR parola, -parola). Filtri: `kind` (snciv|snpen), `anno_from`/`anno_to` (anno di deposito; `anno_from` non può superare `anno_to`), `sezione` e `materia` (uguaglianza esatta, maiuscole comprese). `k` 1..50 (default 20).
- `it-giurisprudenza_cassazione_sentenza` (ecli e/o source_id): gli estremi di una sentenza. L''ECLI non è un''identità: una sentenza civile e una penale possono condividerlo, quindi vengono restituite tutte (al massimo 5); `source_id` è unico.
Copertura: solo il 2021 e anni seguenti; prima non c''è testo.

## Corti di giustizia tributaria
- `it-giurisprudenza_cgt_search`: ricerca ibrida; filtri `grado` (1|2), `luogo` (esatto, es. Campania), `anno_from`/`anno_to`. `k` 1..50 (default 20).
- `it-giurisprudenza_cgt_pronuncia` (id uuid): gli estremi di una decisione.
Copertura: solo le Corti di giustizia tributaria dopo la riforma; i documenti che il MEF pubblica senza testo non sono ricercabili (il loro numero è in `it-giurisprudenza_status`).

## Flussi
- Cerca: `it-giurisprudenza_search` → `it-giurisprudenza_pronuncia` / `it-giurisprudenza_massime`
- Da norma a sentenze: URN della norma (dal corpus normativo) → `it-giurisprudenza_sentenze_su_norma`
- Cassazione: `it-giurisprudenza_cassazione_search` → `it-giurisprudenza_cassazione_sentenza` → `source_url`
- Tributaria: `it-giurisprudenza_cgt_search` → `it-giurisprudenza_cgt_pronuncia` → `source_url`

## Limiti
- `k` ≤ 50; senza servizio di embedding la ricerca ibrida torna solo il lessicale
- i passaggi non ancora vettorizzati non partecipano alla ricerca semantica (vedi `passages_without_embedding`)
- citare sempre la fonte: Corte costituzionale (CC BY-SA 3.0), Corte di cassazione / CED, MEF DocTrib' AS text
