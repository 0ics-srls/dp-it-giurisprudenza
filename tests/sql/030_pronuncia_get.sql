-- pronuncia: one row per ecli with every section; optional sections and the decision date may be NULL
INSERT INTO pronunce (ecli, anno, numero, tipologia, presidente, data_decisione, epigrafe, diritto, text_raw) VALUES
 ('ECLI:IT:COST:2093:1', 2093, 1, 'S', 'P', DATE '2093-01-10', 'EPIGRAFE', 'DIRITTO', 'tutto'),
 ('ECLI:IT:COST:2093:2', 2093, 2, 'O', NULL, NULL, NULL, NULL, 'ordinanza');

SELECT (SELECT count(*) FROM pronunce WHERE ecli = 'ECLI:IT:COST:2093:1' AND epigrafe = 'EPIGRAFE' AND diritto = 'DIRITTO' AND fatto IS NULL AND source_url = 'https://www.cortecostituzionale.it/scheda-pronuncia/2093/1') = 1
   AND (SELECT count(*) FROM pronunce WHERE ecli = 'ECLI:IT:COST:2093:2' AND data_decisione IS NULL AND epigrafe IS NULL) = 1 AS ok
