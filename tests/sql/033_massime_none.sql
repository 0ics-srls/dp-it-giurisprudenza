-- massime: a decision without massime and an unknown decision both give zero rows (legacy: empty list vs 404; the package answers no rows for both)
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2090:1', 2090, 1, 'S', 'x');

SELECT (SELECT count(*) FROM massime WHERE ecli = 'ECLI:IT:COST:2090:1') = 0
   AND (SELECT count(*) FROM massime WHERE ecli = 'ECLI:IT:COST:2090:404') = 0 AS ok
