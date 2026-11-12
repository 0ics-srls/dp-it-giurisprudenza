-- dp-it-giurisprudenza 0002: full-text (italian), links, vector index, lookup indexes, out-of-line original text.

ALTER TABLE pronunce ADD COLUMN search_vector tsvector GENERATED ALWAYS AS (to_tsvector('italian', text_raw)) STORED;
ALTER TABLE pronunce ADD COLUMN source_url text GENERATED ALWAYS AS ('https://www.cortecostituzionale.it/scheda-pronuncia/' || anno || '/' || numero) STORED;
ALTER TABLE massime ADD COLUMN search_vector tsvector GENERATED ALWAYS AS (to_tsvector('italian', text_raw)) STORED;
ALTER TABLE cassazione_sentenze ADD COLUMN search_vector tsvector GENERATED ALWAYS AS (to_tsvector('italian', text_anon)) STORED;
ALTER TABLE cgt_sentenze ADD COLUMN search_vector tsvector GENERATED ALWAYS AS (to_tsvector('italian', text_anon)) STORED;

-- The act part of norma_urn (before the article separator) joins the registries to it-normativa acts.
ALTER TABLE norme_impugnate ADD COLUMN norma_act_urn text GENERATED ALWAYS AS (split_part(norma_urn, '~', 1)) STORED;

CREATE INDEX pronunce_search_vector_idx ON pronunce USING gin (search_vector);
CREATE INDEX pronunce_anno_idx ON pronunce (anno, tipologia);
CREATE INDEX massime_search_vector_idx ON massime USING gin (search_vector);
CREATE INDEX massime_ecli_idx ON massime (ecli);
CREATE INDEX cassazione_sentenze_search_vector_idx ON cassazione_sentenze USING gin (search_vector);
CREATE INDEX cassazione_sentenze_kind_anno_idx ON cassazione_sentenze (kind, anno);
CREATE INDEX cassazione_sentenze_anno_num_dec_idx ON cassazione_sentenze (anno, num_dec);
CREATE INDEX cassazione_sentenze_ecli_idx ON cassazione_sentenze (ecli);
CREATE INDEX cassazione_sentenze_sezione_anno_idx ON cassazione_sentenze (sezione, anno);
CREATE INDEX cassazione_sentenze_materia_idx ON cassazione_sentenze (materia);
CREATE INDEX cgt_sentenze_search_vector_idx ON cgt_sentenze USING gin (search_vector);
CREATE INDEX cgt_sentenze_grado_anno_idx ON cgt_sentenze (grado, anno);
CREATE INDEX cgt_sentenze_luogo_anno_idx ON cgt_sentenze (luogo, anno);
CREATE INDEX cgt_sentenze_data_idx ON cgt_sentenze (data);
CREATE INDEX norme_impugnate_norma_urn_idx ON norme_impugnate (norma_urn text_pattern_ops);
CREATE INDEX norme_impugnate_norma_act_urn_idx ON norme_impugnate (norma_act_urn);
CREATE INDEX norme_impugnate_ecli_idx ON norme_impugnate (ecli);
CREATE INDEX passages_embedding_hnsw_idx ON passages USING hnsw (embedding vector_cosine_ops);
CREATE INDEX passages_corpus_doc_key_idx ON passages (corpus, doc_key);

-- The original (non anonymized) text stays out of line and uncompressed.
ALTER TABLE cassazione_sentenze ALTER COLUMN text_raw_original SET STORAGE EXTERNAL;
ALTER TABLE cgt_sentenze ALTER COLUMN text_raw_original SET STORAGE EXTERNAL;
