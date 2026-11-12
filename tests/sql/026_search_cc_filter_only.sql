-- search (CC), filter-only listing: decisions ordered by ecli, capped at k (the legacy ORDER BY ecli LIMIT k)
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES
 ('ECLI:IT:COST:2096:3', 2096, 3, 'S', 'c'), ('ECLI:IT:COST:2096:1', 2096, 1, 'S', 'a'), ('ECLI:IT:COST:2096:2', 2096, 2, 'O', 'b');

SELECT (SELECT array_agg(ecli ORDER BY ecli) FROM (SELECT ecli FROM pronunce WHERE anno = 2096 ORDER BY ecli LIMIT 2) t)
         = ARRAY['ECLI:IT:COST:2096:1', 'ECLI:IT:COST:2096:2'] AS ok
