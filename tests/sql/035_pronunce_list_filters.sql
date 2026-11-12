-- pronunce_list: filters anno, tipologia and an ecli fragment (ILIKE with literal % and _); massime_count is the number of massime of the decision
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES
 ('ECLI:IT:COST:2088:1', 2088, 1, 'S', 'a'), ('ECLI:IT:COST:2088:2', 2088, 2, 'O', 'b'), ('ECLI:IT:COST:2087:1', 2087, 1, 'S', 'c');
INSERT INTO massime (ecli, numero, text_raw) VALUES ('ECLI:IT:COST:2088:1', 1, 'm1'), ('ECLI:IT:COST:2088:1', 2, 'm2');

SELECT (SELECT count(*) FROM pronunce WHERE anno = 2088 AND tipologia = 'O') = 1
   AND (SELECT count(*) FROM pronunce WHERE ecli ILIKE '%' || replace(replace(replace('cost:2088', '\', '\\'), '%', '\%'), '_', '\_') || '%') = 2
   AND (SELECT count(*) FROM pronunce WHERE ecli ILIKE '%' || replace(replace(replace('%', '\', '\\'), '%', '\%'), '_', '\_') || '%') = 0
   AND (SELECT count(*) FROM massime WHERE ecli = 'ECLI:IT:COST:2088:1') = 2 AS ok
