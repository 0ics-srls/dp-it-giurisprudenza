INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES ('ECLI:IT:COST:2001:1', 2001, 1, 'S', 'testo');

SELECT source_url = 'https://www.cortecostituzionale.it/scheda-pronuncia/2001/1' AS ok FROM pronunce WHERE ecli = 'ECLI:IT:COST:2001:1'
