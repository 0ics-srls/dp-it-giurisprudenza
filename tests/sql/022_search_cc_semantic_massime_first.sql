-- search (CC), semantic side: massime FIRST by cosine distance, then pronunce; the positions of the second block continue after the first
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('massima', 'ECLI:IT:COST:2098:21', 1, 'm', 'm', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('pronuncia', 'ECLI:IT:COST:2098:21', 1, 'p', 'p', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('pronuncia', 'ECLI:IT:COST:2098:22', 1, 'q', 'q', (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH qv AS (SELECT (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024) AS v),
     semm AS (
         SELECT 'massima' AS source, doc_key, row_number() OVER (ORDER BY embedding <=> qv.v, doc_key) AS rn
           FROM passages, qv WHERE corpus = 'massima' AND doc_key LIKE 'ECLI:IT:COST:2098:%'),
     semp AS (
         SELECT 'pronuncia' AS source, doc_key, (SELECT count(*) FROM semm) + row_number() OVER (ORDER BY embedding <=> qv.v, doc_key) AS rn
           FROM passages, qv WHERE corpus = 'pronuncia' AND doc_key LIKE 'ECLI:IT:COST:2098:%'),
     sem AS (SELECT * FROM semm UNION ALL SELECT * FROM semp)
SELECT (SELECT array_agg(source || '|' || doc_key ORDER BY rn) FROM sem)
         = ARRAY['massima|ECLI:IT:COST:2098:21', 'pronuncia|ECLI:IT:COST:2098:21', 'pronuncia|ECLI:IT:COST:2098:22']
   AND (SELECT array_agg(rn ORDER BY rn) FROM sem) = ARRAY[1::bigint, 2, 3] AS ok
