-- search (CC), degraded: no query vector (no capability / no provider) casts to NULL, the semantic list is empty and nothing raises
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('pronuncia', 'ECLI:IT:COST:2095:1', 1, 'x', 'x', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH prm AS (SELECT CAST(NULL AS vector) AS qv)
SELECT (SELECT count(*) FROM passages, prm WHERE corpus = 'pronuncia' AND prm.qv IS NOT NULL AND embedding IS NOT NULL) = 0
   AND (SELECT count(*) FROM passages WHERE corpus = 'pronuncia' AND doc_key = 'ECLI:IT:COST:2095:1' AND embedding IS NOT NULL) = 1 AS ok
