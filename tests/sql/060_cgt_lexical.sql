-- cgt_search, lexical: the anonymized text is searched and highlighted, the original text is not
INSERT INTO cgt_sentenze (id, tipo, grado, anno, estremi, text_raw_original, text_anon, source_url) VALUES
 ('00000000-0000-0000-0000-0000000000a0', 'Sentenza', 2, 2070, 'e', 'Mario Rossi originale', 'La societa ha impugnato l''avviso di accertamento', 'u');

SELECT (SELECT count(*) FROM cgt_sentenze WHERE anno = 2070 AND search_vector @@ websearch_to_tsquery('italian', '"avviso di accertamento"')) = 1
   AND (SELECT count(*) FROM cgt_sentenze WHERE anno = 2070 AND search_vector @@ websearch_to_tsquery('italian', 'Rossi')) = 0
   AND (SELECT ts_headline('italian', text_anon, websearch_to_tsquery('italian', 'accertamento'), 'StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8')
          FROM cgt_sentenze WHERE anno = 2070) LIKE '%«accertamento»%' AS ok
