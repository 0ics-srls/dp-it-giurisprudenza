-- cassazione_search mode lexical: the Host skips the query embedding (x-embed.skipWhen) and binds q_vec NULL; the lexical rows are exactly those of a call that had a vector
INSERT INTO cassazione_sentenze (source_id, kind, anno, text_raw_original, text_anon, source_url) VALUES
 ('t074a', 'snciv', 2081, 'orig a', 'Il recesso dal contratto di locazione è valido.', 'u'),
 ('t074b', 'snciv', 2081, 'orig b', 'Il recesso e la locazione sono distinti dalla risoluzione.', 'u'),
 ('t074c', 'snciv', 2081, 'orig c', 'La prescrizione decorre dal deposito.', 'u');
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('cassazione', 't074a', 1, 'x', 'x', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('cassazione', 't074b', 1, 'x', 'x', (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH calls AS (
    SELECT 'with_vector' AS name, 'lexical' AS mode, CAST((ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024) AS text) AS q_vec
    UNION ALL
    SELECT 'null_vector', 'lexical', CAST(NULL AS text)
),
result AS (
    SELECT c.name,
           (SELECT array_agg(f.source_id ORDER BY f.rn)
              FROM (SELECT s.source_id, row_number() OVER (ORDER BY ts_rank_cd(s.search_vector, websearch_to_tsquery('italian', 'recesso locazione')) DESC, s.source_id) AS rn
                      FROM cassazione_sentenze s
                     WHERE s.anno = 2081 AND c.mode <> 'semantic' AND s.search_vector @@ websearch_to_tsquery('italian', 'recesso locazione')) f) AS lexical_rows,
           (SELECT count(*) FROM passages ps
             WHERE ps.corpus = 'cassazione' AND ps.doc_key LIKE 't074%' AND c.mode <> 'lexical' AND CAST(c.q_vec AS vector) IS NOT NULL AND ps.embedding IS NOT NULL) AS semantic_rows
      FROM calls c
)
SELECT (SELECT count(*) FROM result) = 2
   AND (SELECT count(DISTINCT lexical_rows) FROM result) = 1
   AND (SELECT lexical_rows FROM result WHERE name = 'null_vector') @> ARRAY['t074a', 't074b']
   AND (SELECT cardinality(lexical_rows) FROM result WHERE name = 'null_vector') = 2
   AND (SELECT max(semantic_rows) FROM result) = 0 AS ok
