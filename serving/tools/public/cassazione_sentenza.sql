-- Extremes of the sentences with an ecli and/or a source id (all matches, at most 5). POSTURE: no full text; the snippet is the first stored passage capped to 1500 characters,
-- else the first 200 characters of text_anon. text_raw_original is never referenced.
SELECT s.source_id,
       s.ecli,
       s.kind,
       s.sezione,
       s.anno,
       s.num_dec,
       s.data_decisione,
       s.materia,
       s.tipo_prov,
       COALESCE(left((SELECT ps.text FROM passages ps WHERE ps.corpus = 'cassazione' AND ps.doc_key = s.source_id ORDER BY ps.seq LIMIT 1), 1500),
                left(s.text_anon, 200)) AS snippet,
       s.source_url
  FROM cassazione_sentenze s
 WHERE (@ecli IS NULL OR s.ecli = @ecli)
   AND (@source_id IS NULL OR s.source_id = @source_id)
   AND (@ecli IS NOT NULL OR @source_id IS NOT NULL)
 ORDER BY s.data_decisione DESC NULLS LAST, s.source_id
 LIMIT 5
