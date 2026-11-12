-- sentenze_su_norma: an URN no registry row mentions gives zero rows
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_urn) VALUES ('ordinanze', 2080, 1, 0, 'urn:nir:stato:legge:2080-01-01;5~art1');

WITH q(urn) AS (VALUES ('urn:nir:stato:legge:1999-01-01;1'))
SELECT (SELECT count(*) FROM norme_impugnate n, q
         WHERE n.norma_urn = q.urn OR n.norma_urn = split_part(q.urn, '~', 1) OR starts_with(n.norma_urn, split_part(q.urn, '~', 1) || '~')) = 0 AS ok
