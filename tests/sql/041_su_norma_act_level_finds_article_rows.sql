-- sentenze_su_norma: an act-level query finds the rows stored at any article of the act
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_urn) VALUES
 ('ordinanze', 2085, 1, 0, 'urn:nir:stato:legge:2085-01-01;5~art1'),
 ('ordinanze', 2085, 2, 0, 'urn:nir:stato:legge:2085-01-01;5~art9');

WITH q(urn) AS (VALUES ('urn:nir:stato:legge:2085-01-01;5'))
SELECT (SELECT count(*) FROM norme_impugnate n, q
         WHERE n.norma_urn = q.urn OR n.norma_urn = split_part(q.urn, '~', 1) OR starts_with(n.norma_urn, split_part(q.urn, '~', 1) || '~')) = 2 AS ok
