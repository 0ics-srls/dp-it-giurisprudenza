-- search (CC), snippets: a massima snippet is its first 200 characters, a decision without a matched chunk shows the first 200 of the text, a chunk is capped at 1500
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2094:1', 2094, 1, 'S', repeat('abcdefghij', 100));
INSERT INTO massime (ecli, numero, text_raw) VALUES ('ECLI:IT:COST:2094:1', 1, repeat('klmnopqrst', 100));
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual) VALUES ('pronuncia', 'ECLI:IT:COST:2094:1', 1, repeat('z', 3000), repeat('z', 3000));

SELECT (SELECT length(left(text_raw, 200)) FROM massime WHERE ecli = 'ECLI:IT:COST:2094:1') = 200
   AND (SELECT left(text_raw, 200) FROM pronunce WHERE ecli = 'ECLI:IT:COST:2094:1') = repeat('abcdefghij', 20)
   AND (SELECT length(left(text, 1500)) FROM passages WHERE doc_key = 'ECLI:IT:COST:2094:1') = 1500 AS ok
