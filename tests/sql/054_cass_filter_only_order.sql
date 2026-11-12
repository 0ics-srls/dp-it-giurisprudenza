-- cassazione_search, filter-only: newest decision first, sentences without a decision date last, source id breaks ties
INSERT INTO cassazione_sentenze (source_id, kind, anno, data_decisione, text_raw_original, text_anon, source_url) VALUES
 ('t054a', 'snciv', 2075, DATE '2075-01-01', 'o', 'a', 'u'), ('t054b', 'snciv', 2075, NULL, 'o', 'b', 'u'),
 ('t054c', 'snciv', 2075, DATE '2075-06-01', 'o', 'c', 'u'), ('t054d', 'snciv', 2075, DATE '2075-06-01', 'o', 'd', 'u');

SELECT (SELECT array_agg(source_id ORDER BY data_decisione DESC NULLS LAST, source_id) FROM cassazione_sentenze WHERE source_id LIKE 't054%')
         = ARRAY['t054c', 't054d', 't054a', 't054b'] AS ok
