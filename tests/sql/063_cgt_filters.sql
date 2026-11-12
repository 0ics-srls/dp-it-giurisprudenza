-- cgt_search, filters: grado, exact case-sensitive luogo, year range
INSERT INTO cgt_sentenze (id, tipo, grado, luogo, anno, estremi, text_raw_original, text_anon, source_url) VALUES
 ('00000000-0000-0000-0000-0000000000b1', 'Sentenza', 1, 'Campania', 2068, 'e', 'o', 'a', 'u'),
 ('00000000-0000-0000-0000-0000000000b2', 'Sentenza', 2, 'Lazio', 2067, 'e', 'o', 'b', 'u');

SELECT (SELECT count(*) FROM cgt_sentenze WHERE anno IN (2067, 2068) AND grado = 2) = 1
   AND (SELECT count(*) FROM cgt_sentenze WHERE anno IN (2067, 2068) AND luogo = 'Campania') = 1
   AND (SELECT count(*) FROM cgt_sentenze WHERE anno IN (2067, 2068) AND luogo = 'campania') = 0
   AND (SELECT count(*) FROM cgt_sentenze WHERE anno >= 2068 AND anno <= 2068) = 1 AS ok
