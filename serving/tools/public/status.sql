-- Live counts per corpus (port of the LexCoverageResource entries); the limits are text, the numbers are read from the tables. Always three rows, also on an empty database.
SELECT 'cc' AS corpus,
       (SELECT count(*) FROM pronunce) AS documents,
       (SELECT count(*) FROM massime) AS massime,
       (SELECT count(*) FROM passages WHERE corpus IN ('pronuncia', 'massima')) AS passages,
       (SELECT count(*) FROM passages WHERE corpus IN ('pronuncia', 'massima') AND embedding IS NULL) AS passages_without_embedding,
       NULL::timestamptz AS last_ingested_at,
       (SELECT count(*) FROM norme_impugnate WHERE pending) AS norme_pending,
       (SELECT count(*) FROM norme_impugnate n WHERE n.ecli IS NOT NULL AND EXISTS (SELECT 1 FROM pronunce p WHERE p.ecli = n.ecli)) AS norme_resolved,
       (SELECT count(*) FROM norme_impugnate WHERE ecli IS NULL) AS norme_unresolved,
       NULL::bigint AS skipped_without_text,
       'Corte costituzionale, open data CC BY-SA 3.0, testo integrale. I registri delle norme impugnate elencano cause pendenti: il collegamento a una decisione passa dal numero di registro citato nell''epigrafe e l''assenza di risultati non prova che non esistano pronunce.' AS note
UNION ALL
SELECT 'cassazione',
       (SELECT count(*) FROM cassazione_sentenze),
       0,
       (SELECT count(*) FROM passages WHERE corpus = 'cassazione'),
       (SELECT count(*) FROM passages WHERE corpus = 'cassazione' AND embedding IS NULL),
       (SELECT max(ingested_at) FROM cassazione_sentenze),
       NULL, NULL, NULL, NULL,
       'Corte di cassazione (ItalGiure): solo dal 2021, civile e penale. Mai il testo integrale: estremi, estratto e link alla fonte. L''ECLI non è un''identità: usare source_id.'
UNION ALL
SELECT 'cgt',
       (SELECT count(*) FROM cgt_sentenze),
       0,
       (SELECT count(*) FROM passages WHERE corpus = 'cgt'),
       (SELECT count(*) FROM passages WHERE corpus = 'cgt' AND embedding IS NULL),
       (SELECT max(ingested_at) FROM cgt_sentenze),
       NULL, NULL, NULL,
       (SELECT count(*) FROM cgt_skipped),
       'Corti di giustizia tributaria (MEF DocTrib), solo dopo la riforma. Mai il testo integrale: estremi, estratto e link alla fonte. I documenti senza testo alla fonte non sono ricercabili (skipped_without_text).'
