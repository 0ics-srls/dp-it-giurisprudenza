INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_descrizione) VALUES ('ordinanze', 2099, 5, 0, 'legge');

DO $$
BEGIN
    INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_descrizione) VALUES ('ordinanze', 2099, 5, 0, 'altra');
    RAISE EXCEPTION 'duplicate natural key was accepted';
EXCEPTION WHEN unique_violation THEN
    NULL;
END $$;

-- accumulation defaults: a new row is pending and carries first_seen / last_seen, no decision is linked yet
SELECT count(*) = 1 AS ok FROM norme_impugnate
WHERE registro_numero = 5 AND pending AND first_seen IS NOT NULL AND last_seen IS NOT NULL AND ecli IS NULL
