-- cgt_pronuncia: the decision by uuid; the first stored passage is the snippet, else the start of the anonymized text
INSERT INTO cgt_sentenze (id, tipo, grado, anno, estremi, text_raw_original, text_anon, source_url) VALUES
 ('00000000-0000-0000-0000-0000000000d1', 'Sentenza', 1, 2065, 'e', 'o', 'testo anonimizzato', 'u');
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual) VALUES
 ('cgt', '00000000-0000-0000-0000-0000000000d1', 2, 'secondo', 'x'), ('cgt', '00000000-0000-0000-0000-0000000000d1', 1, 'primo', 'x');

SELECT (SELECT ps.text FROM passages ps WHERE ps.corpus = 'cgt' AND ps.doc_key = '00000000-0000-0000-0000-0000000000d1' ORDER BY ps.seq LIMIT 1) = 'primo'
   AND (SELECT count(*) FROM cgt_sentenze WHERE id = CAST('00000000-0000-0000-0000-0000000000D1' AS uuid)) = 1 AS ok
