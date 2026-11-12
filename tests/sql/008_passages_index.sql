SELECT (SELECT count(*) FROM pg_indexes WHERE schemaname = current_schema() AND tablename = 'passages' AND indexdef ILIKE '%hnsw%' AND indexdef ILIKE '%vector_cosine_ops%') = 1
   AND (SELECT count(*) FROM pg_indexes WHERE schemaname = current_schema() AND tablename = 'passages' AND indexdef ILIKE '%(corpus, doc_key)%') >= 1
   AND (SELECT format_type(a.atttypid, a.atttypmod) FROM pg_attribute a WHERE a.attrelid = 'passages'::regclass AND a.attname = 'embedding') = 'vector(1024)' AS ok
