-- the generated search vectors use the italian configuration: the stem of "licenziamento" matches "licenziare"
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2099:9', 2099, 9, 'S', 'Il datore di lavoro non puo licenziare il lavoratore senza giusta causa');
INSERT INTO massime (ecli, numero, titolo, text_raw) VALUES ('ECLI:IT:COST:2099:9', 1, 't', 'Il licenziamento illegittimo e sanzionato');
INSERT INTO cassazione_sentenze (source_id, kind, anno, text_raw_original, text_anon, source_url)
VALUES ('t5', 'snciv', 2025, 'originale riservato', 'Il datore ha licenziato il dipendente', 'u');
INSERT INTO cgt_sentenze (id, tipo, grado, anno, estremi, text_raw_original, text_anon, source_url)
VALUES ('00000000-0000-0000-0000-000000000005', 'Sentenza', 1, 2024, 'e', 'originale riservato', 'La societa ha impugnato gli avvisi di accertamento', 'u');

SELECT (SELECT count(*) FROM pronunce WHERE search_vector @@ websearch_to_tsquery('italian', 'licenziamento')) = 1
   AND (SELECT count(*) FROM massime WHERE search_vector @@ websearch_to_tsquery('italian', 'licenziare')) = 1
   AND (SELECT count(*) FROM cassazione_sentenze WHERE search_vector @@ websearch_to_tsquery('italian', 'licenziamento')) = 1
   AND (SELECT count(*) FROM cgt_sentenze WHERE search_vector @@ websearch_to_tsquery('italian', 'impugnare accertamento')) = 1
   -- the search vector of a sentence is built from the anonymized text only, never from the original
   AND (SELECT count(*) FROM cassazione_sentenze WHERE search_vector @@ websearch_to_tsquery('italian', 'riservato')) = 0 AS ok
