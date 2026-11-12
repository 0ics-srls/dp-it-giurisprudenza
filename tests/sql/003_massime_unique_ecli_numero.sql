INSERT INTO massime (ecli, numero, titolo, text_raw) VALUES ('ECLI:IT:COST:2099:1', 1, 'titolo', 'massima');

DO $$
BEGIN
    INSERT INTO massime (ecli, numero, titolo, text_raw) VALUES ('ECLI:IT:COST:2099:1', 1, 'altro', 'altra massima');
    RAISE EXCEPTION 'duplicate (ecli, numero) was accepted';
EXCEPTION WHEN unique_violation THEN
    NULL;
END $$;

-- another massima number of the same decision is fine
INSERT INTO massime (ecli, numero, titolo, text_raw) VALUES ('ECLI:IT:COST:2099:1', 2, 'titolo 2', 'seconda massima');

SELECT count(*) = 2 AS ok FROM massime WHERE ecli = 'ECLI:IT:COST:2099:1'
