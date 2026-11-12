# dp-it-giurisprudenza

Data Package `it-giurisprudenza` (phase 79, open-lex-it): Italian case law in three corpora, loaded by a six-step pipeline into the schema `ds_it_giurisprudenza` and served by 11 Tools. Version 0.2.0 adds three Console Screens (see Screens); 0.1.0 had none.

| Corpus | Source | Licence name (Manifest) |
|---|---|---|
| Corte costituzionale: pronunce, massime, norme impugnate | `dati.cortecostituzionale.it` open data dumps | `CC-BY-SA-3.0` |
| Corte di cassazione, civil (`snciv`) and criminal (`snpen`), 2021 onwards | ItalGiure SentenzeWeb (CED) | `no-open-licence-internal-use` |
| Corti di giustizia tributaria, first and second grade | MEF DocTrib | `source-terms-not-published` |

## Pipeline

`detect` -> `grab` -> `convert` -> `anonymize` -> `ingest` -> `embed`, one pipeline for every Source type (a step with nothing to do for a kind passes through: Corte costituzionale skips the NER, CGT runs only the PII guardrail). The five own classes are the repos `dp-it-giurisprudenza-{detect,grab,convert,anonymize,ingest}`, pinned to tags in `dataplatform.json`; `embed` is the shared `dp-lex-embed` (`dp-p7.1`) and fills the NULL vectors of `passages`. Items: a Corte costituzionale dump, a Cassazione partition (kind x year x month, 13 = residual) or a CGT calendar-month window. Every Source takes the common settings `refreshToken`, `tokenBudget` (hard stop of Jina tokens per Run, default 30000) and `dryRun` (the embedding step plans only: no Jina call, nothing written).

## Source types and sample settings

| Source type | Settings | Sample |
|---|---|---|
| `cc-opendata` | `bundles` (pronunce_*, massime_*, norme_*), `anni`, `only` | `{"bundles": ["norme_ordinanze", "pronunce_2001_oggi", "massime_2001_oggi"], "only": [{"anno": 2026, "numero": 95}], "dryRun": true}` |
| `cassazione-solr` | `kind`, `anno`, `mese`, `maxDocs`, `solrBaseUrl`, `verifyTls` | `{"kind": "snciv", "anno": 2025, "mese": 1, "maxDocs": 5}` |
| `cgt-doctrib` | `from`, `to`, `maxItems`, `verifyTls` | `{"from": "2024-12-01", "to": "2024-12-31", "maxItems": 3}` |

Load the `norme_*` registries before the pronunce (or load the pronunce again): a registry row links to a decision only when it exists at the moment the decision is loaded. Cassazione access note: `www.italgiure.giustizia.it` is not reachable from every network (it refused connections from the development machine); `solrBaseUrl` lets a replay server stand in, and a real fetch needs an Italian egress.

## Tools (Gateway prefix `it-giurisprudenza_`)

| Tool | Purpose | Legacy |
|---|---|---|
| `it-giurisprudenza_search` | Corte costituzionale, massime + pronunce, hybrid (FTS italian + vector, RRF) | `search_giuris` |
| `it-giurisprudenza_pronuncia` | one decision, every section (open data) | `get_pronuncia` |
| `it-giurisprudenza_massime` | massime of a decision, in number order | `get_massime` |
| `it-giurisprudenza_sentenze_su_norma` | registry rows by norm URN, with the decision when linked | `get_sentenze_su_norma` |
| `it-giurisprudenza_pronunce_list` | paged list (Screens) | new |
| `it-giurisprudenza_cassazione_search` | Cassazione, hybrid, extremes + snippet + link | `search_cassazione` |
| `it-giurisprudenza_cassazione_sentenza` | extremes of a sentence by ecli and/or source_id | `get_sentenza_cassazione` |
| `it-giurisprudenza_cgt_search` | CGT, hybrid, extremes + snippet + link | `search_giur_tributaria` |
| `it-giurisprudenza_cgt_pronuncia` | extremes of a decision by id | `get_pronuncia_cgt` |
| `it-giurisprudenza_guide` | the manual (Italian) | `CorpusGuide` |
| `it-giurisprudenza_status` | live counts and limits per corpus | `lex://coverage` |

A k above 50 is a 400 (k is 1..50); `mode` is hybrid, lexical or semantic. Without a query vector (no embedding capability) the hybrid search answers lexically. Results are in relevance order, with a `position`, and no numeric score.

### Deviations from the legacy (notes P79-09, P79-10, P79-12)

- Hybrid pattern as dp-it-normativa (two lists, RRF k = 60, ties lexical first), regconfig `'italian'`; the semantic side runs on `passages` (best chunk per document, pool `max(200, 20*take)`). For `search` the massime list comes first and the pronunce positions continue after it, so massime outrank decisions under RRF.
- Snippets are capped: a chunk at 1500 characters (the legacy returned the whole chunk, up to 8000), a massima or a text fallback at 200.
- `massime` answers no rows both for an unknown decision (legacy 404) and for a decision without massime (legacy empty list).
- `sentenze_su_norma` keeps the legacy matching (the URN, the act, or any article of the act: `norma_articolo` narrows) and its honesty (`unresolved_registri`); new: decisions are linked through the registry number quoted in the epigrafe (the legacy never linked any). The registries are accumulative (rows are never deleted, `pending` marks the latest snapshot).
- `anno_from` above `anno_to` (Cassazione, CGT) is a 400; `luogo`, `sezione` and `materia` are exact, case-sensitive matches as in the legacy.
- `text_raw_original`, the non anonymized text, is stored and never returned by anything.

## Screens (since 0.2.0)

Angular custom elements served from the committed `ui/dist` (built with `npm ci && npm run build` in `ui/`, see `ui/BUILD-NOTES.md`); Console menu "Italian case law" (sk / it / en).

| Screen | Element | Shows |
|---|---|---|
| `corpus` (default) | `dp-it-giurisprudenza-corpus` | three tabs: Costituzionale (search or paged list, filters kind and years), Cassazione (kind, years, section, subject), Tributaria (instance, place, years); extremes, excerpt and source link only for Cassazione and CGT |
| `decision` | `dp-it-giurisprudenza-decision` | route key `cc~<ecli>`, `cass~<source_id or ecli>`, `cgt~<id>` (raw, never pre-encoded): CC full text with sections, massime and a norm box (`sentenze_su_norma`); Cassazione and CGT extremes, excerpt and link, never the full text |
| `status` | `dp-it-giurisprudenza-status` | counts per corpus, embedding warning, honest limits and the licence footer |

The Screens call only the ten Tools of their permissions (`pronunce_list`, `search`, `pronuncia`, `massime`, `sentenze_su_norma`, `cassazione_search`, `cassazione_sentenza`, `cgt_search`, `cgt_pronuncia`, `status`) and `navigate`. A year range without text is listed with `search` (up to 50, no paging); one year is paged with `pronunce_list`.

## Legal posture

Corte costituzionale data is open (CC BY-SA 3.0): attribute the source; derivatives stay CC BY-SA. Cassazione and CGT are not open data: the Tools return the extremes, a highlight or a passage of at most 1500 characters, and the source link, never the full text. The rule is data, not convention: the columns `text_raw_original`, `text_anon`, `ocr_dis_anon` and the passage texts carry the ODCS `largeValue` flag, so the Host generated Tools cannot return them, and `DpItGiurisprudenzaPostureTests` fails if a Tool SQL reads `text_raw_original`, selects `text_anon` or passage text uncapped, or if any output exceeds the cap. The Manifest licences keep a public Grant blocked until the ItalGiure (CED) and MEF DocTrib terms are confirmed.

## Schema

`ds_it_giurisprudenza` (7 tables, migrations `0001_init.sql`, `0002_search.sql`): `pronunce`, `massime`, `norme_impugnate`, `cassazione_sentenze`, `cgt_sentenze`, `passages` (every embeddable piece of every corpus, `vector(1024)` with an HNSW cosine index), `cgt_skipped` (documents without text at the source, counted by `status`). The contract `serving/dataset.odcs.yaml` has `references` from `norma_urn` and `norma_act_urn` to the `it-normativa` units; the link stays metadata, no Tool reads another package.

## Tests

`tests/sql` (one `ok` row each), `tests/tools` (one call per Tool), and the C# suites `DpItGiurisprudenza*` in `tests/DataPlatform.Registry.Tests` of open-lex-it, which run the real Tool SQL through the Host binder. Parity: the Corte costituzionale Tools are compared with the legacy at the umbrella HEAD, Cassazione and CGT with the legacy branch 53 or its fixtures (phase 79 plan-d).
