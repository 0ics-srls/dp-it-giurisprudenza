-- search (CC), RRF (k = 60, 1-based): a row in both lists beats rows in one, a tie goes to the lexical side, the pronunce positions continue after the massime block
WITH lex(key, rn) AS (VALUES ('p:3', 1), ('m:1', 2), ('p:2', 3)),
     semm(key, rn) AS (VALUES ('m:9', 1)),
     semp(key, rn) AS (SELECT key, (SELECT count(*) FROM semm) + rn FROM (VALUES ('p:3', 1), ('p:7', 2)) v(key, rn)),
     sem AS (SELECT * FROM semm UNION ALL SELECT * FROM semp),
     fused AS (
         SELECT COALESCE(l.key, s.key) AS key,
                COALESCE(1.0 / (60 + l.rn), 0) + COALESCE(1.0 / (60 + s.rn), 0) AS rrf,
                COALESCE(l.rn, 1000000000) AS lex_rn,
                COALESCE(s.rn, 1000000000) AS sem_rn
           FROM lex l FULL OUTER JOIN sem s ON s.key = l.key),
     picked AS (SELECT key, row_number() OVER (ORDER BY rrf DESC, lex_rn, sem_rn, key) AS pos FROM fused)
-- p:3 is in both lists (1/61 + 1/62); m:9 = 1/61 (semantic 1), m:1 = 1/62, then p:2 (lexical 3) and p:7 (semantic 3) tie at 1/63 and the lexical side goes first
SELECT (SELECT array_agg(key ORDER BY pos) FROM picked) = ARRAY['p:3', 'm:9', 'm:1', 'p:2', 'p:7'] AS ok
