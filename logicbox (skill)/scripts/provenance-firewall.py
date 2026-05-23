#!/usr/bin/env python3
"""Pre-Shen firewall: verify every argumentative fact has a provenance tag.

Three required tags:
  [translator-added ID extracted]  — content from the prose
  [translator-added ID inferred]   — logically required, not stated
  [translator-added ID added]      — translator invention

Argumentative fact types that require tags:
  claim, condition, ground-claim, mechanism, definition,
  objection, rebuttal, value-conclusion

Exempt: plan, plan-*, comment, term, protected, infers-to,
        objects-to, rebuts, impacts, risks, reason-type,
        sufficiency, modality, scope-status, stage-*, context-*,
        adapter-*, implies, denies, conflicts, undermines,
        exempts, translator-added (the tag itself)

Output: exits 0 (all tagged) or 1 with list of untagged facts.
"""

import re
import sys
from pathlib import Path


ARGUMENTATIVE_TYPES = {
    'claim', 'condition', 'ground-claim', 'mechanism',
    'definition', 'objection', 'rebuttal', 'value-conclusion',
}


def parse_facts(filepath: str) -> dict[str, list[list[str]]]:
    facts: dict[str, list[list[str]]] = {}
    with open(filepath) as f:
        text = f.read()
    pattern = re.compile(r'\[(\S+)\s+((?:[^\[\]]|\[[^\]]*\])*)\]')
    for m in pattern.finditer(text):
        ftype = m.group(1)
        tokens = tokenize(m.group(2))
        facts.setdefault(ftype, []).append(tokens)
    return facts


def tokenize(s: str) -> list[str]:
    tokens = []
    current = []
    in_quote = False
    for ch in s:
        if ch == '"':
            in_quote = not in_quote
            current.append(ch)
        elif ch.isspace() and not in_quote:
            if current:
                tokens.append(''.join(current))
                current = []
        else:
            current.append(ch)
    if current:
        tokens.append(''.join(current))
    return tokens


def get_ids_from_fact(ftype: str, tokens: list[str]) -> list[str]:
    """Extract the fact's own ID(s) from its tokens.

    claim/condition/ground-claim/objection/rebuttal/value-conclusion:
      first token is the ID
    mechanism:
      second token is the mechanism ID (first is the claim it attaches to)
    definition:
      first token is the symbol being defined
    """
    if not tokens:
        return []
    if ftype == 'mechanism':
        if len(tokens) >= 2:
            return [tokens[1]]
        return []
    if ftype == 'definition':
        return [tokens[0]]
    if ftype in ARGUMENTATIVE_TYPES:
        return [tokens[0]]
    return []


def main():
    facts_path = sys.argv[1] if len(sys.argv) > 1 else 'work/ai-facts.shen'

    if not Path(facts_path).exists():
        print(f"PROVENANCE-FIREWALL: {facts_path} not found — skipping")
        sys.exit(0)

    facts = parse_facts(facts_path)

    # Collect all IDs from argumentative facts
    all_argument_ids: set[str] = set()
    for ftype in ARGUMENTATIVE_TYPES:
        for tokens in facts.get(ftype, []):
            ids = get_ids_from_fact(ftype, tokens)
            all_argument_ids.update(ids)

    # Collect all IDs that have provenance tags
    tagged_ids: set[str] = set()
    for tokens in facts.get('translator-added', []):
        if len(tokens) >= 2:
            tagged_ids.add(tokens[0])

    # Find untagged argumentative IDs
    untagged = all_argument_ids - tagged_ids

    if untagged:
        print("PROVENANCE-FIREWALL: untagged argumentative facts detected")
        print("Every claim, condition, ground-claim, mechanism, definition,")
        print("objection, rebuttal, and value-conclusion must have a provenance tag:")
        print()
        print("  [translator-added ID extracted]   — content from the prose")
        print("  [translator-added ID inferred]    — logically required, not stated")
        print("  [translator-added ID added]       — translator invention")
        print()
        print("Untagged IDs:")
        for uid in sorted(untagged):
            # Find which fact type this ID belongs to
            for ftype in ARGUMENTATIVE_TYPES:
                for tokens in facts.get(ftype, []):
                    ids = get_ids_from_fact(ftype, tokens)
                    if uid in ids:
                        print(f"  {uid}  ({ftype})")
                        break
        print()
        print(f"FIX: add [translator-added {list(untagged)[0]} <extracted|inferred|added>]")
        print(f"for each untagged ID above.")
        sys.exit(1)
    else:
        tagged_count = len(tagged_ids)
        print(f"PROVENANCE-FIREWALL: all {tagged_count} argumentative facts tagged")
        sys.exit(0)


if __name__ == '__main__':
    main()
