-- cassazione_search, semantic: the nearest chunk per sentence (DISTINCT ON doc_key) among the passages of the cassazione corpus only
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('cassazione', 't051', 1, 'lontano', 'x', (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('cassazione', 't051', 2, 'vicino', 'x', (ARRAY[0.9, 0.1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('cgt', 't051', 1, 'altro corpus', 'x', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH qv AS (SELECT (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024) AS v),
     chunks AS (
         SELECT doc_key, text, embedding <=> qv.v AS dist FROM passages, qv
          WHERE corpus = 'cassazione' AND doc_key = 't051' AND embedding IS NOT NULL ORDER BY dist LIMIT 200),
     best AS (SELECT DISTINCT ON (doc_key) doc_key, text FROM chunks ORDER BY doc_key, dist)
SELECT (SELECT count(*) FROM best) = 1 AND (SELECT text FROM best) = 'vicino' AS ok
