-- sentenze_su_norma: a registry row whose ecli names a loaded decision is resolved; a row without ecli is counted as unresolved (window FILTER)
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2081:1', 2081, 1, 'S', 'x');
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_urn, ecli) VALUES
 ('ordinanze', 2081, 1, 0, 'urn:nir:stato:legge:2081-01-01;5~art1', 'ECLI:IT:COST:2081:1'),
 ('ordinanze', 2081, 2, 0, 'urn:nir:stato:legge:2081-01-01;5~art1', NULL);

WITH r AS (
    SELECT n.registro_numero, (n.ecli IS NOT NULL AND p.ecli IS NOT NULL) AS resolved,
           count(*) FILTER (WHERE n.ecli IS NULL) OVER () AS unresolved_registri
      FROM norme_impugnate n LEFT JOIN pronunce p ON p.ecli = n.ecli
     WHERE n.registro_anno = 2081)
SELECT (SELECT resolved FROM r WHERE registro_numero = 1) AND NOT (SELECT resolved FROM r WHERE registro_numero = 2)
   AND (SELECT min(unresolved_registri) FROM r) = 1 AS ok
