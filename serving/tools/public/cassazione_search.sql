-- cassazione_search: hybrid pattern of search.sql on cassazione_sentenze / passages (corpus cassazione, doc_key = source_id).
-- POSTURE: only text_anon is read, and only through ts_headline, left(...) or a passage capped to 1500 characters; text_raw_original is never referenced.
--   lex   : parent lexical list by ts_rank_cd on search_vector (source_id breaks ties), 2*k rows.
--   chunks/best/sem : nearest chunk per sentence (pool max(200, 20*take)), parents filtered through the join, 2*k rows.
--   fused : FULL OUTER JOIN on source_id, RRF k = 60, ties lexical first. Filter-only: newest decision first, undated last.
--   snippet: headline (capped) > best chunk (capped 1500) > first 200 characters of text_anon.
--   guard : anno_from > anno_to raises 22P02 (a Host 400); it sits in the outer WHERE as a one-time filter so it fires even when no row is read.
WITH prm AS (
    SELECT NULLIF(btrim(@query), '') AS query,
           LEAST(GREATEST(COALESCE(@k, 20), 1), 50)::int AS k,
           COALESCE(NULLIF(btrim(@mode), ''), 'hybrid') AS mode,
           CAST(@q_vec AS vector) AS qv
),
p AS (
    SELECT s.source_id, s.search_vector, s.data_decisione
      FROM cassazione_sentenze s
     WHERE (@kind IS NULL OR s.kind = @kind)
       AND (@anno_from IS NULL OR s.anno >= @anno_from)
       AND (@anno_to IS NULL OR s.anno <= @anno_to)
       AND (@sezione IS NULL OR s.sezione = @sezione)
       AND (@materia IS NULL OR s.materia = @materia)
),
tsq AS (
    SELECT CASE WHEN prm.query IS NOT NULL THEN websearch_to_tsquery('italian', prm.query) END AS q FROM prm
),
lex AS (
    SELECT r.source_id, r.rn
      FROM (
            SELECT p.source_id, row_number() OVER (ORDER BY ts_rank_cd(p.search_vector, tsq.q) DESC, p.source_id) AS rn
              FROM p, tsq, prm
             WHERE prm.query IS NOT NULL AND prm.mode <> 'semantic' AND p.search_vector @@ tsq.q
           ) r
     ORDER BY r.rn
     LIMIT (SELECT 2 * k FROM prm)
),
chunks AS (
    SELECT ps.doc_key, ps.text, ps.embedding <=> prm.qv AS dist
      FROM passages ps
      JOIN p ON p.source_id = ps.doc_key
     CROSS JOIN prm
     WHERE ps.corpus = 'cassazione' AND prm.query IS NOT NULL AND prm.mode <> 'lexical' AND prm.qv IS NOT NULL AND ps.embedding IS NOT NULL
     ORDER BY dist
     LIMIT (SELECT GREATEST(200, 20 * 2 * k) FROM prm)
),
best AS (
    SELECT DISTINCT ON (c.doc_key) c.doc_key, c.text, c.dist FROM chunks c ORDER BY c.doc_key, c.dist
),
sem AS (
    SELECT r.source_id, r.chunk, r.rn
      FROM (SELECT b.doc_key AS source_id, b.text AS chunk, row_number() OVER (ORDER BY b.dist, b.doc_key) AS rn FROM best b) r
     ORDER BY r.rn
     LIMIT (SELECT 2 * k FROM prm)
),
fused AS (
    SELECT COALESCE(l.source_id, s.source_id) AS source_id, s.chunk,
           COALESCE(1.0 / (60 + l.rn), 0) + COALESCE(1.0 / (60 + s.rn), 0) AS rrf,
           COALESCE(l.rn, 1000000000) AS lex_rn,
           COALESCE(s.rn, 1000000000) AS sem_rn
      FROM lex l
      FULL OUTER JOIN sem s ON s.source_id = l.source_id
),
picked AS (
    (SELECT f.source_id, f.chunk, f.lex_rn, row_number() OVER (ORDER BY f.rrf DESC, f.lex_rn, f.sem_rn, f.source_id) AS pos
       FROM fused f
      ORDER BY pos
      LIMIT (SELECT k FROM prm))
    UNION ALL
    (SELECT p.source_id, NULL::text, 1000000000::bigint, row_number() OVER (ORDER BY p.data_decisione DESC NULLS LAST, p.source_id)
       FROM p, prm
      WHERE prm.query IS NULL
      ORDER BY p.data_decisione DESC NULLS LAST, p.source_id
      LIMIT (SELECT k FROM prm))
)
SELECT s.source_id,
       s.ecli,
       s.kind,
       s.sezione,
       s.anno,
       s.num_dec,
       s.data_decisione,
       s.materia,
       s.tipo_prov,
       h.headline,
       COALESCE(h.headline, left(k.chunk, 1500), left(s.text_anon, 200)) AS snippet,
       s.source_url,
       k.pos AS "position"
  FROM picked k
  JOIN cassazione_sentenze s ON s.source_id = k.source_id
 CROSS JOIN tsq
 CROSS JOIN LATERAL (
       SELECT CASE WHEN k.lex_rn < 1000000000
                   THEN left(ts_headline('italian', s.text_anon, tsq.q, 'StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8'), 1500)
              END AS headline
 ) h
 WHERE (CASE WHEN @anno_from > @anno_to THEN CAST('anno_from must not exceed anno_to: ' || @anno_from || ' > ' || @anno_to AS integer) END) IS NULL
 ORDER BY k.pos
