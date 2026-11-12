-- cassazione_search, filters: kind, deposit-year range, exact (case-sensitive) sezione and materia
INSERT INTO cassazione_sentenze (source_id, kind, sezione, anno, materia, text_raw_original, text_anon, source_url) VALUES
 ('t053a', 'snciv', '5', 2077, 'Lavoro', 'o', 'a', 'u'),
 ('t053b', 'snpen', 'L', 2076, 'Penale', 'o', 'b', 'u');

SELECT (SELECT count(*) FROM cassazione_sentenze WHERE source_id LIKE 't053%' AND kind = 'snpen') = 1
   AND (SELECT count(*) FROM cassazione_sentenze WHERE source_id LIKE 't053%' AND anno >= 2077) = 1
   AND (SELECT count(*) FROM cassazione_sentenze WHERE source_id LIKE 't053%' AND anno <= 2076) = 1
   AND (SELECT count(*) FROM cassazione_sentenze WHERE source_id LIKE 't053%' AND sezione = 'L') = 1
   AND (SELECT count(*) FROM cassazione_sentenze WHERE source_id LIKE 't053%' AND sezione = 'l') = 0
   AND (SELECT count(*) FROM cassazione_sentenze WHERE source_id LIKE 't053%' AND materia = 'lavoro') = 0 AS ok
