-- two decisions with the same (anno, numero) are refused even under different ecli; the ecli itself is the key
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2099:1', 2099, 1, 'S', 'testo');

DO $$
BEGIN
    INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2099:1bis', 2099, 1, 'S', 'altro');
    RAISE EXCEPTION 'duplicate anno/numero was accepted';
EXCEPTION WHEN unique_violation THEN
    NULL;
END $$;

DO $$
BEGIN
    INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2099:1', 2099, 2, 'S', 'altro');
    RAISE EXCEPTION 'duplicate ecli was accepted';
EXCEPTION WHEN unique_violation THEN
    NULL;
END $$;

SELECT count(*) = 1 AS ok FROM pronunce WHERE anno = 2099
