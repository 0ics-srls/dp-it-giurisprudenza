-- cgt_search: RRF over the decision id (both-list row first, tie lexical first); a missing query vector gives an empty semantic side
WITH lex(id, rn) AS (VALUES ('g1', 1), ('g3', 2)),
     sem(id, rn) AS (VALUES ('g3', 1), ('g2', 2)),
     hybrid AS (
         SELECT COALESCE(l.id, s.id) AS id, COALESCE(1.0 / (60 + l.rn), 0) + COALESCE(1.0 / (60 + s.rn), 0) AS rrf,
                COALESCE(l.rn, 1000000000) AS lex_rn, COALESCE(s.rn, 1000000000) AS sem_rn
           FROM lex l FULL OUTER JOIN sem s ON s.id = l.id),
     prm AS (SELECT CAST(NULL AS vector) AS qv)
SELECT (SELECT array_agg(id ORDER BY rrf DESC, lex_rn, sem_rn, id) FROM hybrid) = ARRAY['g3', 'g1', 'g2']
   AND (SELECT qv IS NULL FROM prm) AS ok
