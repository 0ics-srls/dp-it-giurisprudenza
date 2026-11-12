-- sentenze_su_norma: the legacy matching (equal, act, or act~ prefix with starts_with) finds the row stored at the queried article
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_urn, norma_articolo) VALUES
 ('ordinanze', 2086, 1, 0, 'urn:nir:stato:legge:2086-01-01;197~art1', '1'),
 ('ordinanze', 2086, 2, 0, 'urn:nir:stato:legge:2086-01-01;197~art7', '7');

WITH q(urn) AS (VALUES ('urn:nir:stato:legge:2086-01-01;197~art1')),
     m AS (
         SELECT n.* FROM norme_impugnate n, q
          WHERE n.norma_urn = q.urn OR n.norma_urn = split_part(q.urn, '~', 1) OR starts_with(n.norma_urn, split_part(q.urn, '~', 1) || '~'))
SELECT (SELECT count(*) FROM m WHERE registro_anno = 2086 AND norma_articolo = '1') = 1
   AND (SELECT count(*) FROM m WHERE registro_anno = 2086) = 2 AS ok
