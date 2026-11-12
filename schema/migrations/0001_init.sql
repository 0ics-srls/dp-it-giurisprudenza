-- dp-it-giurisprudenza 0001: the seven giurisprudenza tables. Additive only; applied by the Host as ds_it_giurisprudenza_rw with search_path ds_it_giurisprudenza, public.
-- No foreign keys: the legacy chunk -> parent FK is replaced by ingest-side replacement in one transaction. The pgvector extension is provided by the Host.

-- Corte costituzionale decisions (open data, CC BY-SA 3.0). Key: the ECLI assigned by the Court.
CREATE TABLE pronunce (
    ecli text PRIMARY KEY,
    anno integer NOT NULL,
    numero integer NOT NULL,
    tipologia text NOT NULL,
    presidente text,
    relatore text,
    redattore text,
    data_decisione date,
    data_deposito date,
    collegio text,
    epigrafe text,
    fatto text,
    diritto text,
    testo text,
    dispositivo text,
    text_raw text NOT NULL,
    CONSTRAINT pronunce_tipologia_chk CHECK (tipologia IN ('S', 'O')),
    CONSTRAINT pronunce_anno_numero_uq UNIQUE (anno, numero)
);

-- Massime are child rows of a decision (P79-06): key (ecli, numero).
CREATE TABLE massime (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ecli text NOT NULL,
    numero integer NOT NULL,
    titolo text,
    text_raw text NOT NULL,
    CONSTRAINT massime_ecli_numero_uq UNIQUE (ecli, numero)
);

-- Registries of referral orders / appeals / conflicts, ACCUMULATIVE (P79-12): upsert on the natural key, never deleted.
CREATE TABLE norme_impugnate (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registro_tipo text NOT NULL,
    registro_anno integer NOT NULL,
    registro_numero integer NOT NULL,
    ord integer NOT NULL,
    norma_descrizione text,
    norma_numero text,
    norma_data text,
    norma_articolo text,
    norma_comma text,
    norma_specificazione_articolo text,
    norma_specificazione_comma text,
    norma_nesso text,
    norma_urn text,
    ecli text,
    ecli_via text,
    pending boolean NOT NULL DEFAULT true,
    first_seen timestamptz NOT NULL DEFAULT now(),
    last_seen timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT norme_impugnate_registro_tipo_chk CHECK (registro_tipo IN ('ordinanze', 'ricorsi', 'conflitti_enti', 'conflitti_poteri')),
    CONSTRAINT norme_impugnate_natural_key_uq UNIQUE (registro_tipo, registro_anno, registro_numero, ord)
);

-- Cassazione sentences (ItalGiure). Key: the Solr id. ecli is NOT unique and not an identity (P79-05).
-- text_raw_original is retained and never served; text_anon is what search and passages use.
CREATE TABLE cassazione_sentenze (
    source_id text PRIMARY KEY,
    kind text NOT NULL,
    ecli text,
    sezione text,
    anno integer NOT NULL,
    num_dec integer,
    data_decisione date,
    data_deposito date,
    presidente text,
    relatore text,
    materia text,
    tipo_prov text,
    text_raw_original text NOT NULL,
    text_anon text NOT NULL,
    ocr_dis_anon text,
    redaction_report jsonb,
    source_url text NOT NULL,
    ingested_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT cassazione_sentenze_kind_chk CHECK (kind IN ('snciv', 'snpen'))
);

-- Tax justice decisions (MEF DocTrib). Key: the DocTrib GUID.
CREATE TABLE cgt_sentenze (
    id uuid PRIMARY KEY,
    tipo text NOT NULL,
    data date,
    grado smallint NOT NULL,
    luogo text,
    sezione text,
    numero integer,
    anno integer NOT NULL,
    estremi text NOT NULL,
    text_raw_original text NOT NULL,
    text_anon text NOT NULL,
    redaction_report jsonb,
    source_url text NOT NULL,
    ingested_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT cgt_sentenze_grado_chk CHECK (grado IN (1, 2))
);

-- Every embeddable piece of every corpus (P79-07): pronuncia bodies, massime, Cassazione bodies, CGT bodies. Headers are not stored.
CREATE TABLE passages (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    corpus text NOT NULL,
    doc_key text NOT NULL,
    seq integer NOT NULL,
    kind text NOT NULL DEFAULT 'body',
    text text NOT NULL,
    text_contextual text NOT NULL,
    embedding vector(1024),
    CONSTRAINT passages_corpus_chk CHECK (corpus IN ('pronuncia', 'massima', 'cassazione', 'cgt')),
    CONSTRAINT passages_corpus_doc_seq_uq UNIQUE (corpus, doc_key, seq)
);

-- CGT documents that have no text at the source: skipped and counted for the honest coverage figure.
CREATE TABLE cgt_skipped (
    guid uuid PRIMARY KEY,
    estremi text,
    reason text NOT NULL,
    seen_at timestamptz NOT NULL DEFAULT now()
);
