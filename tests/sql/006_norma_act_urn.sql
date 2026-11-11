-- the act urn is the part of norma_urn before the article separator
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_urn)
VALUES ('ordinanze', 2099, 1, 0, 'urn:nir:stato:decreto.legislativo:2001-03-15;388~art80'),
       ('ordinanze', 2099, 1, 1, 'urn:nir:stato:legge:2022-12-29;197'),
       ('ordinanze', 2099, 1, 2, NULL);

SELECT (SELECT norma_act_urn FROM norme_impugnate WHERE registro_numero = 1 AND ord = 0) = 'urn:nir:stato:decreto.legislativo:2001-03-15;388'
   AND (SELECT norma_act_urn FROM norme_impugnate WHERE registro_numero = 1 AND ord = 1) = 'urn:nir:stato:legge:2022-12-29;197'
   AND (SELECT norma_act_urn FROM norme_impugnate WHERE registro_numero = 1 AND ord = 2) IS NULL AS ok
