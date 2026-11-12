-- posture: the original CGT text stays out of the search vector and out of what a Tool returns; the Tool files are scanned by DpItGiurisprudenzaPostureTests in the Registry test project
INSERT INTO cgt_sentenze (id, tipo, grado, anno, estremi, text_raw_original, text_anon, source_url) VALUES
 ('00000000-0000-0000-0000-0000000000e1', 'Sentenza', 1, 2064, 'e', 'ORIGINALE RISERVATO', repeat('x', 5000), 'u');

SELECT (SELECT length(left(text_anon, 1500)) FROM cgt_sentenze WHERE anno = 2064) = 1500
   AND (SELECT count(*) FROM cgt_sentenze WHERE anno = 2064 AND search_vector @@ websearch_to_tsquery('italian', 'riservato')) = 0 AS ok
