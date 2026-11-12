-- search (CC): massime and pronunce are ONE lexical list; the union keeps the kind of every hit and the massima number
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2098:11', 2098, 11, 'S', 'Il recesso del lavoratore e illegittimo.');
INSERT INTO massime (ecli, numero, titolo, text_raw) VALUES ('ECLI:IT:COST:2098:11', 1, 'Lavoro', 'Il recesso illegittimo comporta la reintegrazione.');

WITH q AS (SELECT websearch_to_tsquery('italian', 'recesso') AS q),
     hits AS (
         SELECT 'massima' AS source, m.ecli, m.numero FROM massime m, q WHERE m.search_vector @@ q.q
         UNION ALL
         SELECT 'pronuncia', p.ecli, 0 FROM pronunce p, q WHERE p.search_vector @@ q.q)
SELECT (SELECT count(*) FROM hits WHERE ecli = 'ECLI:IT:COST:2098:11') = 2
   AND (SELECT count(*) FROM hits WHERE source = 'massima' AND numero = 1 AND ecli = 'ECLI:IT:COST:2098:11') = 1
   AND (SELECT count(*) FROM hits WHERE source = 'pronuncia' AND numero = 0 AND ecli = 'ECLI:IT:COST:2098:11') = 1 AS ok
