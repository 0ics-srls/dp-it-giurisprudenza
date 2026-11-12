-- cassazione_search snippet: headline first, then the best chunk (cap 1500), then the first 200 characters of the anonymized text
INSERT INTO cassazione_sentenze (source_id, kind, anno, text_raw_original, text_anon, source_url) VALUES
 ('t056', 'snciv', 2074, 'o', repeat('parola ', 100), 'u');
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual) VALUES ('cassazione', 't056', 1, repeat('c', 4000), 'x');

SELECT COALESCE(NULL::text, left((SELECT text FROM passages WHERE doc_key = 't056'), 1500), left((SELECT text_anon FROM cassazione_sentenze WHERE source_id = 't056'), 200)) = repeat('c', 1500)
   AND COALESCE(NULL::text, NULL::text, left((SELECT text_anon FROM cassazione_sentenze WHERE source_id = 't056'), 200)) = left(repeat('parola ', 100), 200)
   AND length(left((SELECT text FROM passages WHERE doc_key = 't056'), 1500)) = 1500 AS ok
