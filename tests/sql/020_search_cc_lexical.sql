-- search (CC), lexical side: websearch syntax on the italian vectors of pronunce and massime, headline with the legacy markers
INSERT INTO pronunce (ecli, anno, numero, tipologia, text_raw) VALUES
 ('ECLI:IT:COST:2098:1', 2098, 1, 'S', 'La licenza edilizia è rilasciata dal comune entro trenta giorni.'),
 ('ECLI:IT:COST:2098:2', 2098, 2, 'S', 'Il permesso sostituisce la licenza urgente edilizia nei casi previsti.'),
 ('ECLI:IT:COST:2098:3', 2098, 3, 'S', 'La sanzione amministrativa è applicata dal prefetto.');

SELECT (SELECT count(*) FROM pronunce WHERE anno = 2098 AND search_vector @@ websearch_to_tsquery('italian', '"licenza edilizia"')) = 1
   AND (SELECT count(*) FROM pronunce WHERE anno = 2098 AND search_vector @@ websearch_to_tsquery('italian', 'sanzione OR permesso')) = 2
   AND (SELECT count(*) FROM pronunce WHERE anno = 2098 AND search_vector @@ websearch_to_tsquery('italian', 'licenza -comune')) = 1
   AND (SELECT count(*) FROM pronunce WHERE anno = 2098 AND search_vector @@ websearch_to_tsquery('italian', 'licenza sanzione')) = 0
   AND (SELECT ts_headline('italian', text_raw, websearch_to_tsquery('italian', 'sanzione'), 'StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8')
          FROM pronunce WHERE ecli = 'ECLI:IT:COST:2098:3') LIKE '%«sanzione»%' AS ok
