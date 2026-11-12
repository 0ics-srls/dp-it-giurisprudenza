-- cassazione_search, RRF over the sentence id: lexical c1 c3, semantic c3 c2 give c3 (both lists), c1, c2; mode lexical / semantic keep one list
WITH lex(id, rn) AS (VALUES ('c1', 1), ('c3', 2)),
     sem(id, rn) AS (VALUES ('c3', 1), ('c2', 2)),
     hybrid AS (
         SELECT COALESCE(l.id, s.id) AS id, COALESCE(1.0 / (60 + l.rn), 0) + COALESCE(1.0 / (60 + s.rn), 0) AS rrf,
                COALESCE(l.rn, 1000000000) AS lex_rn, COALESCE(s.rn, 1000000000) AS sem_rn
           FROM lex l FULL OUTER JOIN sem s ON s.id = l.id)
SELECT (SELECT array_agg(id ORDER BY rrf DESC, lex_rn, sem_rn, id) FROM hybrid) = ARRAY['c3', 'c1', 'c2']
   AND (SELECT array_agg(id ORDER BY rn) FROM lex) = ARRAY['c1', 'c3']
   AND (SELECT array_agg(id ORDER BY rn) FROM sem) = ARRAY['c3', 'c2'] AS ok
