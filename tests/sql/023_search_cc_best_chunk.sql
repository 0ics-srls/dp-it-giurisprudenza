-- search (CC): three chunks of one decision give ONE hit; the snippet is the chunk nearest to the query (DISTINCT ON over the candidate pool)
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('pronuncia', 'ECLI:IT:COST:2098:31', 1, 'lontano', 'x', (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('pronuncia', 'ECLI:IT:COST:2098:31', 2, 'vicino', 'x', (ARRAY[0.9, 0.1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('pronuncia', 'ECLI:IT:COST:2098:31', 3, 'altro', 'x', (ARRAY[0, 0, 1]::real[] || array_fill(0::real, ARRAY[1021]))::vector(1024));

WITH qv AS (SELECT (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024) AS v),
     chunks AS (
         SELECT doc_key, text, embedding <=> qv.v AS dist FROM passages, qv
          WHERE corpus = 'pronuncia' AND doc_key = 'ECLI:IT:COST:2098:31' AND embedding IS NOT NULL
          ORDER BY dist LIMIT 200),
     best AS (SELECT DISTINCT ON (doc_key) doc_key, text FROM chunks ORDER BY doc_key, dist)
SELECT (SELECT count(*) FROM best) = 1 AND (SELECT text FROM best) = 'vicino' AS ok
