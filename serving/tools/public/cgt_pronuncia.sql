-- Extremes of one decision by its DocTrib id. POSTURE: no full text; the snippet is the first stored passage capped to 1500 characters, else the first 200 characters of text_anon.
-- text_raw_original is never referenced.
SELECT s.id::text AS id,
       s.tipo,
       s.grado,
       s.luogo,
       s.sezione,
       s.anno,
       s.numero,
       s.data,
       s.estremi,
       COALESCE(left((SELECT ps.text FROM passages ps WHERE ps.corpus = 'cgt' AND ps.doc_key = s.id::text ORDER BY ps.seq LIMIT 1), 1500),
                left(s.text_anon, 200)) AS snippet,
       s.source_url
  FROM cgt_sentenze s
 WHERE s.id = CAST(@id AS uuid)
