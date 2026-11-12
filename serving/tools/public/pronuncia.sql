-- One decision by ECLI, every section (the Corte costituzionale data is open: the full text is served). No row = not found.
SELECT p.ecli, p.anno, p.numero, p.tipologia, p.presidente, p.relatore, p.redattore, p.data_decisione, p.data_deposito, p.collegio,
       p.epigrafe, p.fatto, p.diritto, p.testo, p.dispositivo, p.source_url
  FROM pronunce p
 WHERE p.ecli = @ecli
