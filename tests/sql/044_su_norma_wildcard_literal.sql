-- sentenze_su_norma: starts_with is literal, a % or _ in the URN is no wildcard (a LIKE would match everything)
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_urn) VALUES
 ('ordinanze', 2082, 1, 0, 'urn:nir:stato:legge:2082-01-01;5~art1');

WITH q(urn) AS (VALUES ('urn:nir:%'), ('urn:nir:stato:legge:2082-01-01;_'))
SELECT (SELECT count(*) FROM norme_impugnate n, q
         WHERE n.norma_urn = q.urn OR n.norma_urn = split_part(q.urn, '~', 1) OR starts_with(n.norma_urn, split_part(q.urn, '~', 1) || '~')) = 0
   AND (SELECT count(*) FROM norme_impugnate WHERE norma_urn LIKE 'urn:nir:%') >= 1 AS ok
