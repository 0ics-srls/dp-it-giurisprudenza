-- cassazione_search, lexical: the headline is cut from the anonymized text; the original text is not searchable
INSERT INTO cassazione_sentenze (source_id, kind, anno, text_raw_original, text_anon, source_url) VALUES
 ('t050', 'snciv', 2078, 'Mario Rossi ha agito contro Luigi Bianchi per il recesso', 'A.A. ha agito contro B.B. per il recesso dal contratto', 'u');

SELECT (SELECT count(*) FROM cassazione_sentenze WHERE source_id = 't050' AND search_vector @@ websearch_to_tsquery('italian', 'recesso')) = 1
   AND (SELECT count(*) FROM cassazione_sentenze WHERE source_id = 't050' AND search_vector @@ websearch_to_tsquery('italian', 'Rossi')) = 0
   AND (SELECT ts_headline('italian', text_anon, websearch_to_tsquery('italian', 'recesso'), 'StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8')
          FROM cassazione_sentenze WHERE source_id = 't050') LIKE '%«recesso»%' AS ok
