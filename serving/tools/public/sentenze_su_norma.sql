-- Registry rows that mention a norm (legacy get_sentenze_su_norma): equal URN, the act, or any URN starting with act~ (starts_with, so % and _ are literal).
-- The decision comes from the same schema (LEFT JOIN on ecli); resolved only when the decision is loaded. unresolved_registri = rows without an ecli, the legacy honest count.
SELECT n.registro_tipo, n.registro_anno, n.registro_numero, n.norma_urn, n.norma_descrizione, n.norma_articolo, n.norma_comma, n.pending,
       (n.ecli IS NOT NULL AND p.ecli IS NOT NULL) AS resolved,
       n.ecli, p.anno, p.numero, p.tipologia, p.data_deposito, p.source_url,
       count(*) FILTER (WHERE n.ecli IS NULL) OVER () AS unresolved_registri
  FROM norme_impugnate n
  LEFT JOIN pronunce p ON p.ecli = n.ecli
 WHERE n.norma_urn IS NOT NULL
   AND (n.norma_urn = @norma_urn
        OR n.norma_urn = split_part(@norma_urn, '~', 1)
        OR starts_with(n.norma_urn, split_part(@norma_urn, '~', 1) || '~'))
 ORDER BY n.registro_anno DESC, n.registro_tipo, n.registro_numero DESC, n.ord
 LIMIT 500
