-- status: documents the MEF publishes without text are counted in cgt_skipped (the honest coverage figure), not in the decisions
INSERT INTO cgt_skipped (guid, estremi, reason) VALUES
 ('00000000-0000-0000-0000-0000000000f1', 'Sentenza 1', 'no text at the source'), ('00000000-0000-0000-0000-0000000000f2', 'Sentenza 2', 'no text at the source');
INSERT INTO cgt_sentenze (id, tipo, grado, anno, estremi, text_raw_original, text_anon, source_url) VALUES
 ('00000000-0000-0000-0000-0000000000f3', 'Sentenza', 1, 2062, 'e', 'o', 'a', 'u');

SELECT (SELECT count(*) FROM cgt_skipped) = 2
   AND (SELECT count(*) FROM cgt_sentenze WHERE anno = 2062) = 1
   AND (SELECT count(*) FROM cgt_sentenze s JOIN cgt_skipped k ON k.guid = s.id) = 0 AS ok
