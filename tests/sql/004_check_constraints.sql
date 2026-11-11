DO $$
BEGIN
    INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2099:7', 2099, 7, 'X', 'testo');
    RAISE EXCEPTION 'tipologia X was accepted';
EXCEPTION WHEN check_violation THEN
    NULL;
END $$;

DO $$
BEGIN
    INSERT INTO cassazione_sentenze (source_id, kind, anno, text_raw_original, text_anon, source_url) VALUES ('t1', 'snxyz', 2025, 'a', 'b', 'u');
    RAISE EXCEPTION 'kind snxyz was accepted';
EXCEPTION WHEN check_violation THEN
    NULL;
END $$;

DO $$
BEGIN
    INSERT INTO cgt_sentenze (id, tipo, grado, anno, estremi, text_raw_original, text_anon, source_url)
    VALUES ('00000000-0000-0000-0000-000000000003', 'Sentenza', 3, 2024, 'e', 'a', 'b', 'u');
    RAISE EXCEPTION 'grado 3 was accepted';
EXCEPTION WHEN check_violation THEN
    NULL;
END $$;

DO $$
BEGIN
    INSERT INTO passages (corpus, doc_key, seq, kind, text, text_contextual) VALUES ('altro', 'k', 0, 'body', 't', 't');
    RAISE EXCEPTION 'corpus altro was accepted';
EXCEPTION WHEN check_violation THEN
    NULL;
END $$;

-- the legal values are accepted
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2099:8', 2099, 8, 'O', 'testo');
INSERT INTO cassazione_sentenze (source_id, kind, anno, text_raw_original, text_anon, source_url) VALUES ('t2', 'snpen', 2025, 'a', 'b', 'u');
INSERT INTO cgt_sentenze (id, tipo, grado, anno, estremi, text_raw_original, text_anon, source_url)
VALUES ('00000000-0000-0000-0000-000000000002', 'Sentenza', 2, 2024, 'e', 'a', 'b', 'u');
INSERT INTO passages (corpus, doc_key, seq, kind, text, text_contextual) VALUES ('cgt', 'k', 0, 'body', 't', 't');

SELECT true AS ok
