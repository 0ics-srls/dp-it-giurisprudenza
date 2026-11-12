-- cgt_search, semantic: the passage doc_key of the cgt corpus is the decision id as text; the nearest chunk per decision wins
INSERT INTO cgt_sentenze (id, tipo, grado, anno, estremi, text_raw_original, text_anon, source_url) VALUES
 ('00000000-0000-0000-0000-0000000000a1', 'Sentenza', 1, 2069, 'e', 'o', 'a', 'u');
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('cgt', '00000000-0000-0000-0000-0000000000a1', 1, 'lontano', 'x', (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('cgt', '00000000-0000-0000-0000-0000000000a1', 2, 'vicino', 'x', (ARRAY[0.9, 0.1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH qv AS (SELECT (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024) AS v),
     chunks AS (
         SELECT ps.doc_key, ps.text, ps.embedding <=> qv.v AS dist
           FROM passages ps JOIN cgt_sentenze s ON s.id::text = ps.doc_key, qv
          WHERE ps.corpus = 'cgt' AND s.anno = 2069 AND ps.embedding IS NOT NULL ORDER BY dist LIMIT 200),
     best AS (SELECT DISTINCT ON (doc_key) doc_key, text FROM chunks ORDER BY doc_key, dist)
SELECT (SELECT count(*) FROM best) = 1 AND (SELECT text FROM best) = 'vicino' AS ok
