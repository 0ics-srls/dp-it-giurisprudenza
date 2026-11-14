-- cgt_search mode lexical: the Host skips the query embedding (x-embed.skipWhen) and binds q_vec NULL; the lexical rows are exactly those of a call that had a vector
INSERT INTO cgt_sentenze (id, tipo, grado, anno, estremi, text_raw_original, text_anon, source_url) VALUES
 ('00000000-0000-0000-0000-0000000075a1', 'Sentenza', 2, 2061, 'e', 'orig a', 'La societa ha impugnato l''avviso di accertamento.', 'u'),
 ('00000000-0000-0000-0000-0000000075a2', 'Sentenza', 2, 2061, 'e', 'orig b', 'L''avviso di accertamento e la cartella sono distinti.', 'u'),
 ('00000000-0000-0000-0000-0000000075a3', 'Sentenza', 2, 2061, 'e', 'orig c', 'Il ricorso e stato respinto.', 'u');
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('cgt', '00000000-0000-0000-0000-0000000075a1', 1, 'x', 'x', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('cgt', '00000000-0000-0000-0000-0000000075a2', 1, 'x', 'x', (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH calls AS (
    SELECT 'with_vector' AS name, 'lexical' AS mode, CAST((ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024) AS text) AS q_vec
    UNION ALL
    SELECT 'null_vector', 'lexical', CAST(NULL AS text)
),
result AS (
    SELECT c.name,
           (SELECT array_agg(f.id::text ORDER BY f.rn)
              FROM (SELECT s.id, row_number() OVER (ORDER BY ts_rank_cd(s.search_vector, websearch_to_tsquery('italian', 'avviso accertamento')) DESC, s.id) AS rn
                      FROM cgt_sentenze s
                     WHERE s.anno = 2061 AND c.mode <> 'semantic' AND s.search_vector @@ websearch_to_tsquery('italian', 'avviso accertamento')) f) AS lexical_rows,
           (SELECT count(*) FROM passages ps
             WHERE ps.corpus = 'cgt' AND ps.doc_key LIKE '00000000-0000-0000-0000-0000000075a%' AND c.mode <> 'lexical' AND CAST(c.q_vec AS vector) IS NOT NULL AND ps.embedding IS NOT NULL) AS semantic_rows
      FROM calls c
)
SELECT (SELECT count(*) FROM result) = 2
   AND (SELECT count(DISTINCT lexical_rows) FROM result) = 1
   AND (SELECT lexical_rows FROM result WHERE name = 'null_vector') = ARRAY['00000000-0000-0000-0000-0000000075a1', '00000000-0000-0000-0000-0000000075a2']
   AND (SELECT max(semantic_rows) FROM result) = 0 AS ok
