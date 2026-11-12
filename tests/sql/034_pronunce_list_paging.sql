-- pronunce_list: newest first (anno DESC, numero DESC as numbers), limit / offset, the window total counts every matching row
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES
 ('ECLI:IT:COST:2089:1', 2089, 1, 'S', 'a'), ('ECLI:IT:COST:2089:2', 2089, 2, 'S', 'b'), ('ECLI:IT:COST:2089:10', 2089, 10, 'S', 'c'), ('ECLI:IT:COST:2089:3', 2089, 3, 'S', 'd');

WITH page AS (
    SELECT ecli, count(*) OVER () AS total FROM pronunce WHERE anno = 2089 ORDER BY anno DESC, numero DESC LIMIT 2 OFFSET 1)
SELECT (SELECT array_agg(ecli ORDER BY ecli) FROM page) = ARRAY['ECLI:IT:COST:2089:2', 'ECLI:IT:COST:2089:3']
   AND (SELECT min(total) FROM page) = 4 AND (SELECT max(total) FROM page) = 4 AS ok
