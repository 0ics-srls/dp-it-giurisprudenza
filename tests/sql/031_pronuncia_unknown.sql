-- pronuncia: an unknown ecli is no row (the Tool answers not found with zero rows)
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2092:1', 2092, 1, 'S', 'x');

SELECT (SELECT count(*) FROM pronunce WHERE ecli = 'ECLI:IT:COST:2092:99') = 0
   AND (SELECT count(*) FROM pronunce WHERE ecli = 'ECLI:IT:COST:2092:1') = 1 AS ok
