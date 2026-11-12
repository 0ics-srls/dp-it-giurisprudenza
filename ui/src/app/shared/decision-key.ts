/**
 * The detail Screen route parameter: a short key `<kind>~<id>`. The Host encodes `subPath` once (P78-47), so the id goes through RAW (an ECLI holds ':'
 * and must never be pre-encoded with encodeURIComponent); only '/' needs care because it separates route segments.
 */
export type DecisionKind = 'cc' | 'cass' | 'cgt';

export interface DecisionKey {
  readonly kind: DecisionKind;
  readonly id: string;
}

const KINDS: readonly string[] = ['cc', 'cass', 'cgt'];

export function decisionKey(kind: DecisionKind, id: string): string {
  return `${kind}~${id.replaceAll('/', '%2F')}`;
}

/** null when the key is empty, has no known kind or no id (the Screen then shows a hint and calls no Tool). */
export function parseDecisionKey(subPath: string): DecisionKey | null {
  const at = subPath.indexOf('~');
  if (at <= 0) {
    return null;
  }
  const kind = subPath.slice(0, at);
  const id = subPath.slice(at + 1).replaceAll('%2F', '/').trim();
  return KINDS.includes(kind) && id !== '' ? { kind: kind as DecisionKind, id } : null;
}
