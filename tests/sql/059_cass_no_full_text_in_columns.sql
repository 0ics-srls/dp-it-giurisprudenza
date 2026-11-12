-- posture: the text of a sentence is far longer than what a Tool may return; every shape a Tool returns (snippet, headline) is capped at 1500 characters
INSERT INTO cassazione_sentenze (source_id, kind, anno, text_raw_original, text_anon, source_url) VALUES
 ('t059', 'snciv', 2071, repeat('riservato ', 2000), 'recesso ' || repeat('x', 20000), 'u');

SELECT (SELECT length(text_anon) FROM cassazione_sentenze WHERE source_id = 't059') > 20000
   AND (SELECT length(left(text_anon, 1500)) FROM cassazione_sentenze WHERE source_id = 't059') = 1500
   AND (SELECT length(left(ts_headline('italian', text_anon, websearch_to_tsquery('italian', 'recesso'), 'StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8'), 1500))
          FROM cassazione_sentenze WHERE source_id = 't059') <= 1500
   AND (SELECT count(*) FROM cassazione_sentenze WHERE source_id = 't059' AND search_vector @@ websearch_to_tsquery('italian', 'riservato')) = 0 AS ok
