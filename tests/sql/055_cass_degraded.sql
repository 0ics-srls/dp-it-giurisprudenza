-- cassazione_search, degraded: a missing query vector casts to NULL and the semantic candidates are empty
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('cassazione', 't055', 1, 'x', 'x', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH prm AS (SELECT CAST(NULL AS vector) AS qv)
SELECT (SELECT count(*) FROM passages, prm WHERE corpus = 'cassazione' AND prm.qv IS NOT NULL AND embedding IS NOT NULL) = 0 AS ok
