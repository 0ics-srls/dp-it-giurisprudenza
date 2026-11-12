-- cassazione_sentenza: an ECLI is not an identity (P79-05), two sentences can share it and both come back
INSERT INTO cassazione_sentenze (source_id, kind, ecli, anno, text_raw_original, text_anon, source_url) VALUES
 ('t057a', 'snciv', 'ECLI:IT:CASS:2073:33380', 2073, 'o', 'a', 'u'), ('t057b', 'snpen', 'ECLI:IT:CASS:2073:33380', 2073, 'o', 'b', 'u'),
 ('t057c', 'snciv', 'ECLI:IT:CASS:2073:1', 2073, 'o', 'c', 'u');

SELECT (SELECT count(*) FROM cassazione_sentenze WHERE ecli = 'ECLI:IT:CASS:2073:33380') = 2 AS ok
