-- search (CC), filters on the parent decision: tipologia, year range, relatore ILIKE with literal % and _, inclusive deposit range
INSERT INTO pronunce (ecli, anno, numero, tipologia, relatore, data_deposito, text_raw) VALUES
 ('ECLI:IT:COST:2097:1', 2097, 1, 'S', 'Rossi Mario', DATE '2097-02-01', 'a'),
 ('ECLI:IT:COST:2097:2', 2097, 2, 'O', 'Bianchi Anna', DATE '2097-03-01', 'b'),
 ('ECLI:IT:COST:2098:3', 2098, 3, 'S', '100% Neri', DATE '2098-06-15', 'c');

WITH f AS (
    SELECT ecli, tipologia, anno, relatore, data_deposito FROM pronunce WHERE anno >= 2097 AND anno <= 2098)
SELECT (SELECT count(*) FROM f WHERE tipologia = 'O') = 1
   AND (SELECT count(*) FROM f WHERE anno BETWEEN 2098 AND 2098) = 1
   AND (SELECT count(*) FROM f WHERE relatore ILIKE '%rossi%') = 1
   -- % and _ are escaped with a backslash, so they are literal
   AND (SELECT count(*) FROM f WHERE relatore ILIKE '%' || replace(replace(replace('%', '\', '\\'), '%', '\%'), '_', '\_') || '%') = 1
   AND (SELECT count(*) FROM f WHERE relatore ILIKE '%' || replace(replace(replace('s_i', '\', '\\'), '%', '\%'), '_', '\_') || '%') = 0
   AND (SELECT count(*) FROM f WHERE relatore ILIKE '%s_i%') = 1
   AND (SELECT count(*) FROM f WHERE data_deposito >= DATE '2097-03-01' AND data_deposito <= DATE '2098-06-15') = 2 AS ok
