-- cassazione_sentenza: the Solr id is the primary key, exactly one row; an unknown id is no row
INSERT INTO cassazione_sentenze (source_id, kind, ecli, anno, text_raw_original, text_anon, source_url) VALUES
 ('t058a', 'snciv', 'ECLI:IT:CASS:2072:1', 2072, 'o', 'a', 'u');

SELECT (SELECT count(*) FROM cassazione_sentenze WHERE source_id = 't058a') = 1
   AND (SELECT count(*) FROM cassazione_sentenze WHERE source_id = 'nope') = 0 AS ok
