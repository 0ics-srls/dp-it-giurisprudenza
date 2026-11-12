-- sentenze_su_norma: act ;19 must not match act ;197 (the prefix always carries the ~ separator)
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_urn) VALUES
 ('ordinanze', 2083, 1, 0, 'urn:nir:stato:legge:2083-01-01;197~art1'),
 ('ordinanze', 2083, 2, 0, 'urn:nir:stato:legge:2083-01-01;19~art1');

WITH q(urn) AS (VALUES ('urn:nir:stato:legge:2083-01-01;19'))
SELECT (SELECT count(*) FROM norme_impugnate n, q
         WHERE n.norma_urn = q.urn OR n.norma_urn = split_part(q.urn, '~', 1) OR starts_with(n.norma_urn, split_part(q.urn, '~', 1) || '~')) = 1 AS ok
