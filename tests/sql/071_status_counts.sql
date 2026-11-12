-- status: the counts per corpus follow the rows (cc passages = pronuncia + massima kinds), passages_without_embedding counts NULL vectors, norme resolved = ecli names a loaded decision
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2063:1', 2063, 1, 'S', 'x'), ('ECLI:IT:COST:2063:2', 2063, 2, 'O', 'y');
INSERT INTO massime (ecli, numero, text_raw) VALUES ('ECLI:IT:COST:2063:1', 1, 'm');
INSERT INTO passages (corpus, doc_key, seq, text, text_contextual, embedding) VALUES
 ('pronuncia', 'ECLI:IT:COST:2063:1', 1, 'a', 'a', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('massima', 'ECLI:IT:COST:2063:1', 1, 'm', 'm', NULL),
 ('cassazione', 't071', 1, 'c', 'c', NULL);
INSERT INTO norme_impugnate (registro_tipo, registro_anno, registro_numero, ord, ecli, pending) VALUES
 ('ordinanze', 2063, 1, 0, 'ECLI:IT:COST:2063:1', false), ('ordinanze', 2063, 2, 0, NULL, true), ('ordinanze', 2063, 3, 0, 'ECLI:IT:COST:2063:99', true);

SELECT (SELECT count(*) FROM passages WHERE corpus IN ('pronuncia', 'massima') AND doc_key LIKE 'ECLI:IT:COST:2063:%') = 2
   AND (SELECT count(*) FROM passages WHERE corpus IN ('pronuncia', 'massima') AND embedding IS NULL AND doc_key LIKE 'ECLI:IT:COST:2063:%') = 1
   AND (SELECT count(*) FROM passages WHERE corpus = 'cassazione' AND embedding IS NULL) = 1
   AND (SELECT count(*) FROM norme_impugnate n WHERE n.registro_anno = 2063 AND n.ecli IS NOT NULL AND EXISTS (SELECT 1 FROM pronunce p WHERE p.ecli = n.ecli)) = 1
   AND (SELECT count(*) FROM norme_impugnate WHERE registro_anno = 2063 AND ecli IS NULL) = 1
   AND (SELECT count(*) FROM norme_impugnate WHERE registro_anno = 2063 AND pending) = 2 AS ok
