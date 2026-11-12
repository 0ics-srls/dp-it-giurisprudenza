-- massime: ordered by the massima number as a NUMBER (1, 2, 10 - not 1, 10, 2)
INSERT INTO massime (ecli, numero, titolo, text_raw) VALUES
 ('ECLI:IT:COST:2091:1', 10, 't10', 'decima'), ('ECLI:IT:COST:2091:1', 2, 't2', 'seconda'), ('ECLI:IT:COST:2091:1', 1, 't1', 'prima'),
 ('ECLI:IT:COST:2091:2', 1, 'altra', 'di un altra decisione');

SELECT (SELECT array_agg(numero ORDER BY numero) FROM massime WHERE ecli = 'ECLI:IT:COST:2091:1') = ARRAY[1, 2, 10]
   AND (SELECT array_agg(text_raw ORDER BY numero) FROM massime WHERE ecli = 'ECLI:IT:COST:2091:1') = ARRAY['prima', 'seconda', 'decima'] AS ok
