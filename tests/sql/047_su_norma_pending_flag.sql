-- sentenze_su_norma: the pending flag tells whether the case is still in the latest registry snapshot
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, norma_urn, pending) VALUES
 ('ordinanze', 2079, 1, 0, 'urn:nir:stato:legge:2079-01-01;5~art1', true),
 ('ordinanze', 2079, 2, 0, 'urn:nir:stato:legge:2079-01-01;5~art1', false);

SELECT (SELECT count(*) FROM norme_impugnate WHERE registro_anno = 2079 AND pending) = 1
   AND (SELECT count(*) FROM norme_impugnate WHERE registro_anno = 2079 AND NOT pending) = 1 AS ok
