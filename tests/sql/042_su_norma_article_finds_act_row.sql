-- sentenze_su_norma: an article-level query also finds the row stored at the whole act
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_urn) VALUES
 ('ordinanze', 2084, 1, 0, 'urn:nir:stato:legge:2084-01-01;5');

WITH q(urn) AS (VALUES ('urn:nir:stato:legge:2084-01-01;5~art3'))
SELECT (SELECT count(*) FROM norme_impugnate n, q
         WHERE n.norma_urn = q.urn OR n.norma_urn = split_part(q.urn, '~', 1) OR starts_with(n.norma_urn, split_part(q.urn, '~', 1) || '~')) = 1 AS ok
