-- Decisions newest first, filtered by year, kind and an ECLI fragment (% and _ are literal); total counts every matching decision, not the page.
SELECT p.ecli, p.tipologia, p.anno, p.numero, p.data_deposito, p.relatore,
       (SELECT count(*) FROM massime m WHERE m.ecli = p.ecli) AS massime_count,
       count(*) OVER () AS total
  FROM pronunce p
 WHERE (@anno IS NULL OR p.anno = @anno)
   AND (@tipologia IS NULL OR p.tipologia = @tipologia)
   AND (NULLIF(btrim(@q), '') IS NULL OR p.ecli ILIKE '%' || replace(replace(replace(btrim(@q), '\', '\\'), '%', '\%'), '_', '\_') || '%')
 ORDER BY p.anno DESC, p.numero DESC
 LIMIT LEAST(GREATEST(COALESCE(@limit, 50), 1), 100) OFFSET GREATEST(COALESCE(@offset, 0), 0)
