-- The massime of one decision in numeric order (legacy get_massime); the link is the one of the decision.
SELECT m.ecli, m.numero, m.titolo, m.text_raw AS testo, p.source_url
  FROM massime m
  LEFT JOIN pronunce p ON p.ecli = m.ecli
 WHERE m.ecli = @ecli
 ORDER BY m.numero
