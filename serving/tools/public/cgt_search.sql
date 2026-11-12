-- cgt_search: the cassazione_search pattern on cgt_sentenze / passages (corpus cgt, doc_key = id as text). Ordering of the filter-only list: data DESC (undated last), id.
-- POSTURE: only text_anon is read, through ts_headline, left(...) or a passage capped to 1500 characters; text_raw_original is never referenced.
-- guard: anno_from > anno_to raises 22P02 (a Host 400) from a one-time filter in the outer WHERE.
WITH prm AS (
    SELECT NULLIF(btrim(@query), '') AS query,
           LEAST(GREATEST(COALESCE(@k, 20), 1), 50)::int AS k,
           COALESCE(NULLIF(btrim(@mode), ''), 'hybrid') AS mode,
           CAST(@q_vec AS vector) AS qv
),
p AS (
    SELECT s.id::text AS doc_id, s.id, s.search_vector, s.data
      FROM cgt_sentenze s
     WHERE (@grado IS NULL OR s.grado = @grado)
       AND (@luogo IS NULL OR s.luogo = @luogo)
       AND (@anno_from IS NULL OR s.anno >= @anno_from)
       AND (@anno_to IS NULL OR s.anno <= @anno_to)
),
tsq AS (
    SELECT CASE WHEN prm.query IS NOT NULL THEN websearch_to_tsquery('italian', prm.query) END AS q FROM prm
),
lex AS (
    SELECT r.doc_id, r.rn
      FROM (
            SELECT p.doc_id, row_number() OVER (ORDER BY ts_rank_cd(p.search_vector, tsq.q) DESC, p.doc_id) AS rn
              FROM p, tsq, prm
             WHERE prm.query IS NOT NULL AND prm.mode <> 'semantic' AND p.search_vector @@ tsq.q
           ) r
     ORDER BY r.rn
     LIMIT (SELECT 2 * k FROM prm)
),
chunks AS (
    SELECT ps.doc_key, ps.text, ps.embedding <=> prm.qv AS dist
      FROM passages ps
      JOIN p ON p.doc_id = ps.doc_key
     CROSS JOIN prm
     WHERE ps.corpus = 'cgt' AND prm.query IS NOT NULL AND prm.mode <> 'lexical' AND prm.qv IS NOT NULL AND ps.embedding IS NOT NULL
     ORDER BY dist
     LIMIT (SELECT GREATEST(200, 20 * 2 * k) FROM prm)
),
best AS (
    SELECT DISTINCT ON (c.doc_key) c.doc_key, c.text, c.dist FROM chunks c ORDER BY c.doc_key, c.dist
),
sem AS (
    SELECT r.doc_id, r.chunk, r.rn
      FROM (SELECT b.doc_key AS doc_id, b.text AS chunk, row_number() OVER (ORDER BY b.dist, b.doc_key) AS rn FROM best b) r
     ORDER BY r.rn
     LIMIT (SELECT 2 * k FROM prm)
),
fused AS (
    SELECT COALESCE(l.doc_id, s.doc_id) AS doc_id, s.chunk,
           COALESCE(1.0 / (60 + l.rn), 0) + COALESCE(1.0 / (60 + s.rn), 0) AS rrf,
           COALESCE(l.rn, 1000000000) AS lex_rn,
           COALESCE(s.rn, 1000000000) AS sem_rn
      FROM lex l
      FULL OUTER JOIN sem s ON s.doc_id = l.doc_id
),
picked AS (
    (SELECT f.doc_id, f.chunk, f.lex_rn, row_number() OVER (ORDER BY f.rrf DESC, f.lex_rn, f.sem_rn, f.doc_id) AS pos
       FROM fused f
      ORDER BY pos
      LIMIT (SELECT k FROM prm))
    UNION ALL
    (SELECT p.doc_id, NULL::text, 1000000000::bigint, row_number() OVER (ORDER BY p.data DESC NULLS LAST, p.doc_id)
       FROM p, prm
      WHERE prm.query IS NULL
      ORDER BY p.data DESC NULLS LAST, p.doc_id
      LIMIT (SELECT k FROM prm))
)
SELECT s.id::text AS id,
       s.tipo,
       s.grado,
       s.luogo,
       s.sezione,
       s.anno,
       s.numero,
       s.data,
       s.estremi,
       h.headline,
       COALESCE(h.headline, left(k.chunk, 1500), left(s.text_anon, 200)) AS snippet,
       s.source_url,
       k.pos AS "position"
  FROM picked k
  JOIN cgt_sentenze s ON s.id::text = k.doc_id
 CROSS JOIN tsq
 CROSS JOIN LATERAL (
       SELECT CASE WHEN k.lex_rn < 1000000000
                   THEN left(ts_headline('italian', s.text_anon, tsq.q, 'StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8'), 1500)
              END AS headline
 ) h
 WHERE (CASE WHEN @anno_from > @anno_to THEN CAST('anno_from must not exceed anno_to: ' || @anno_from || ' > ' || @anno_to AS integer) END) IS NULL
 ORDER BY k.pos
