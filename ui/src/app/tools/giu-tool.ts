/** The Tools the Screens use; every value must exist in `serving/tools/public` (the contract audit proves it). Bare names (the Gateway prefix is not used by the Console). */
export enum GiuTool {
  PronunceList = 'pronunce_list',
  Search = 'search',
  Pronuncia = 'pronuncia',
  Massime = 'massime',
  SentenzeSuNorma = 'sentenze_su_norma',
  CassazioneSearch = 'cassazione_search',
  CassazioneSentenza = 'cassazione_sentenza',
  CgtSearch = 'cgt_search',
  CgtPronuncia = 'cgt_pronuncia',
  Status = 'status',
}

/** Tool -> the (snake case) input keys its facade method may send; mirrors the `parameters` of the Tool JSON. */
export const TOOL_INPUT_KEYS: Readonly<Record<GiuTool, readonly string[]>> = {
  [GiuTool.PronunceList]: ['anno', 'tipologia', 'q', 'limit', 'offset'],
  [GiuTool.Search]: ['query', 'k', 'mode', 'tipologia', 'anno_from', 'anno_to', 'relatore', 'deposito_from', 'deposito_to'],
  [GiuTool.Pronuncia]: ['ecli'],
  [GiuTool.Massime]: ['ecli'],
  [GiuTool.SentenzeSuNorma]: ['norma_urn'],
  [GiuTool.CassazioneSearch]: ['query', 'k', 'mode', 'kind', 'anno_from', 'anno_to', 'sezione', 'materia'],
  [GiuTool.CassazioneSentenza]: ['ecli', 'source_id'],
  [GiuTool.CgtSearch]: ['query', 'k', 'mode', 'grado', 'luogo', 'anno_from', 'anno_to'],
  [GiuTool.CgtPronuncia]: ['id'],
  [GiuTool.Status]: [],
};
