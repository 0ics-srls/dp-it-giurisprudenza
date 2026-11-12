-- search (Corte costituzionale): port of the legacy search_giuris on the hybrid pattern of dp-it-normativa (two lists, RRF k = 60).
--   prm   : k clamped to 1..50 (default 10), empty strings are NULL, mode default hybrid, query vector from the Host x-embed.
--   p     : the decisions that pass the filters; massime and chunks are filtered through their decision (filters apply to the parent in every branch).
--   lex   : massime and pronunce in ONE list ordered by ts_rank_cd (source, ecli, numero break ties), 2*k rows.
--   semm  : massime by cosine distance of their passage (corpus massima, doc_key = ecli, seq = massima number), 2*k rows, FIRST.
--   semp  : decisions by their nearest chunk (corpus pronuncia): candidate pool max(200, 20*take), DISTINCT ON doc_key, 2*k rows; positions continue after the massime block.
--   fused : FULL OUTER JOIN on source|ecli|massima, RRF = sum 1/(60 + rn), ties lexical first.
--   headline only on the final rows that have a lexical position (null for purely semantic hits); snippet = massima first 200 chars, else best chunk capped at 1500, else first 200 of the text.
WITH prm AS (
    SELECT NULLIF(btrim(@query), '') AS query,
           LEAST(GREATEST(COALESCE(@k, 10), 1), 50)::int AS k,
           COALESCE(NULLIF(btrim(@mode), ''), 'hybrid') AS mode,
           CAST(@q_vec AS vector) AS qv,
           NULLIF(@relatore, '') AS relatore
),
p AS (
    SELECT pr.ecli, pr.search_vector
      FROM pronunce pr, prm
     WHERE (@tipologia IS NULL OR pr.tipologia = @tipologia)
       AND (@anno_from IS NULL OR pr.anno >= @anno_from)
       AND (@anno_to IS NULL OR pr.anno <= @anno_to)
       AND (prm.relatore IS NULL OR pr.relatore ILIKE '%' || replace(replace(replace(prm.relatore, '\', '\\'), '%', '\%'), '_', '\_') || '%')
       AND (@deposito_from IS NULL OR pr.data_deposito >= @deposito_from)
       AND (@deposito_to IS NULL OR pr.data_deposito <= @deposito_to)
),
tsq AS (
    SELECT CASE WHEN prm.query IS NOT NULL THEN websearch_to_tsquery('italian', prm.query) END AS q FROM prm
),
lexc AS (
    SELECT 'massima' AS source, m.ecli, m.numero AS num, ts_rank_cd(m.search_vector, tsq.q) AS rank
      FROM massime m
      JOIN p ON p.ecli = m.ecli
     CROSS JOIN tsq CROSS JOIN prm
     WHERE prm.query IS NOT NULL AND prm.mode <> 'semantic' AND m.search_vector @@ tsq.q
    UNION ALL
    SELECT 'pronuncia', p.ecli, 0, ts_rank_cd(p.search_vector, tsq.q)
      FROM p CROSS JOIN tsq CROSS JOIN prm
     WHERE prm.query IS NOT NULL AND prm.mode <> 'semantic' AND p.search_vector @@ tsq.q
),
lex AS (
    SELECT r.source, r.ecli, r.num, r.rn
      FROM (SELECT l.source, l.ecli, l.num, row_number() OVER (ORDER BY l.rank DESC, l.source, l.ecli, l.num) AS rn FROM lexc l) r
     ORDER BY r.rn
     LIMIT (SELECT 2 * k FROM prm)
),
semm AS (
    SELECT r.source, r.ecli, r.num, r.rn, NULL::text AS chunk
      FROM (
            SELECT 'massima' AS source, m.ecli, m.numero AS num,
                   row_number() OVER (ORDER BY ps.embedding <=> prm.qv, m.ecli, m.numero) AS rn
              FROM passages ps
              JOIN massime m ON ps.doc_key = m.ecli AND ps.seq = m.numero
              JOIN p ON p.ecli = m.ecli
             CROSS JOIN prm
             WHERE ps.corpus = 'massima' AND prm.query IS NOT NULL AND prm.mode <> 'lexical' AND prm.qv IS NOT NULL AND ps.embedding IS NOT NULL
           ) r
     ORDER BY r.rn
     LIMIT (SELECT 2 * k FROM prm)
),
chunks AS (
    SELECT ps.doc_key, ps.text, ps.embedding <=> prm.qv AS dist
      FROM passages ps
      JOIN p ON p.ecli = ps.doc_key
     CROSS JOIN prm
     WHERE ps.corpus = 'pronuncia' AND prm.query IS NOT NULL AND prm.mode <> 'lexical' AND prm.qv IS NOT NULL AND ps.embedding IS NOT NULL
     ORDER BY dist
     LIMIT (SELECT GREATEST(200, 20 * 2 * k) FROM prm)
),
best AS (
    SELECT DISTINCT ON (c.doc_key) c.doc_key, c.text, c.dist FROM chunks c ORDER BY c.doc_key, c.dist
),
semp AS (
    SELECT r.source, r.ecli, r.num, r.rn + (SELECT count(*) FROM semm) AS rn, r.chunk
      FROM (SELECT 'pronuncia' AS source, b.doc_key AS ecli, 0 AS num, b.text AS chunk,
                   row_number() OVER (ORDER BY b.dist, b.doc_key) AS rn
              FROM best b) r
     ORDER BY r.rn
     LIMIT (SELECT 2 * k FROM prm)
),
sem AS (
    SELECT source, ecli, num, rn, chunk FROM semm
    UNION ALL
    SELECT source, ecli, num, rn, chunk FROM semp
),
fused AS (
    SELECT COALESCE(l.source, s.source) AS source, COALESCE(l.ecli, s.ecli) AS ecli, COALESCE(l.num, s.num) AS num, s.chunk,
           COALESCE(1.0 / (60 + l.rn), 0) + COALESCE(1.0 / (60 + s.rn), 0) AS rrf,
           COALESCE(l.rn, 1000000000) AS lex_rn,
           COALESCE(s.rn, 1000000000) AS sem_rn
      FROM lex l
      FULL OUTER JOIN sem s ON s.source = l.source AND s.ecli = l.ecli AND s.num = l.num
),
picked AS (
    (SELECT f.source, f.ecli, f.num, f.chunk, f.lex_rn,
            row_number() OVER (ORDER BY f.rrf DESC, f.lex_rn, f.sem_rn, f.source, f.ecli, f.num) AS pos
       FROM fused f
      ORDER BY pos
      LIMIT (SELECT k FROM prm))
    UNION ALL
    (SELECT 'pronuncia', p.ecli, 0, NULL::text, 1000000000::bigint, row_number() OVER (ORDER BY p.ecli)
       FROM p, prm
      WHERE prm.query IS NULL
      ORDER BY p.ecli
      LIMIT (SELECT k FROM prm))
)
SELECT pr.ecli,
       pr.tipologia,
       pr.anno,
       pr.numero,
       pr.data_deposito,
       k.source,
       CASE WHEN k.source = 'massima' THEN k.num END AS massima_numero,
       m.titolo,
       CASE WHEN k.lex_rn < 1000000000
            THEN ts_headline('italian', COALESCE(m.text_raw, pr.text_raw), tsq.q, 'StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8')
       END AS headline,
       CASE WHEN k.source = 'massima' THEN left(m.text_raw, 200)
            ELSE COALESCE(left(k.chunk, 1500), left(pr.text_raw, 200))
       END AS snippet,
       pr.source_url,
       k.pos AS "position"
  FROM picked k
  JOIN pronunce pr ON pr.ecli = k.ecli
  LEFT JOIN massime m ON k.source = 'massima' AND m.ecli = k.ecli AND m.numero = k.num
 CROSS JOIN tsq
 ORDER BY k.pos
