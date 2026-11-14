-- search (CC) mode lexical: the Host skips the query embedding (x-embed.skipWhen) and binds q_vec NULL; the lexical rows are exactly those of a call that had a vector
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES
 ('ECLI:IT:COST:2091:1', 2091, 1, 'S', 'La licenza edilizia è rilasciata dal comune.'),
 ('ECLI:IT:COST:2091:2', 2091, 2, 'S', 'Il permesso sostituisce la licenza edilizia.'),
 ('ECLI:IT:COST:2091:3', 2091, 3, 'S', 'La sanzione è applicata dal prefetto.');
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('pronuncia', 'ECLI:IT:COST:2091:1', 1, 'x', 'x', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('pronuncia', 'ECLI:IT:COST:2091:2', 1, 'x', 'x', (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH calls AS (
    SELECT 'with_vector' AS name, 'lexical' AS mode, CAST((ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024) AS text) AS q_vec
    UNION ALL
    SELECT 'null_vector', 'lexical', CAST(NULL AS text)
),
result AS (
    SELECT c.name,
           (SELECT array_agg(f.ecli ORDER BY f.rn)
              FROM (SELECT p.ecli, row_number() OVER (ORDER BY ts_rank_cd(p.search_vector, websearch_to_tsquery('italian', 'licenza edilizia')) DESC, p.ecli) AS rn
                      FROM pronunce p
                     WHERE p.anno = 2091 AND c.mode <> 'semantic' AND p.search_vector @@ websearch_to_tsquery('italian', 'licenza edilizia')) f) AS lexical_rows,
           (SELECT count(*) FROM passages ps
             WHERE ps.corpus = 'pronuncia' AND ps.doc_key LIKE 'ECLI:IT:COST:2091:%' AND c.mode <> 'lexical' AND CAST(c.q_vec AS vector) IS NOT NULL AND ps.embedding IS NOT NULL) AS semantic_rows
      FROM calls c
)
SELECT (SELECT count(*) FROM result) = 2
   AND (SELECT count(DISTINCT lexical_rows) FROM result) = 1
   AND (SELECT lexical_rows FROM result WHERE name = 'null_vector') = ARRAY['ECLI:IT:COST:2091:1', 'ECLI:IT:COST:2091:2']
   AND (SELECT max(semantic_rows) FROM result) = 0 AS ok
