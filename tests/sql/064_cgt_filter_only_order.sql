-- cgt_search, filter-only: newest decision date first, undated last, id breaks ties
INSERT INTO cgt_sentenze (id, tipo, grado, anno, data, estremi, text_raw_original, text_anon, source_url) VALUES
 ('00000000-0000-0000-0000-0000000000c1', 'Sentenza', 1, 2066, DATE '2066-01-01', 'e', 'o', 'a', 'u'),
 ('00000000-0000-0000-0000-0000000000c2', 'Sentenza', 1, 2066, NULL, 'e', 'o', 'b', 'u'),
 ('00000000-0000-0000-0000-0000000000c3', 'Sentenza', 1, 2066, DATE '2066-06-01', 'e', 'o', 'c', 'u'),
 ('00000000-0000-0000-0000-0000000000c4', 'Sentenza', 1, 2066, DATE '2066-06-01', 'e', 'o', 'd', 'u');

SELECT (SELECT array_agg(right(id::text, 2) ORDER BY data DESC NULLS LAST, id) FROM cgt_sentenze WHERE anno = 2066) = ARRAY['c3', 'c4', 'c1', 'c2'] AS ok
