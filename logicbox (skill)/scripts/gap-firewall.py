#!/usr/bin/env python3
"""Pre-Shen firewall: detect ground-claims whose source and target symbols
are not connected through any mechanism, definition, or inference chain.

A "connection" exists when:
  - source appears in a mechanism's definition alongside target, OR
  - source appears in a definition that mentions or entails target, OR
  - source and target share a bridging symbol in any mechanism definition

Output: exits 0 (clean) or 1 with a list of disconnected ground-claims.
"""

import re
import sys
from pathlib import Path


def parse_facts(filepath: str) -> dict[str, list[list[str]]]:
    """Parse Shen facts into a dict keyed by fact type."""
    facts: dict[str, list[list[str]]] = {}
    with open(filepath) as f:
        text = f.read()

    # Match [type ...] forms, handling nested brackets minimally
    pattern = re.compile(r'\[(\S+)\s+((?:[^\[\]]|\[[^\]]*\])*)\]')
    for m in pattern.finditer(text):
        ftype = m.group(1)
        # Split the interior into tokens, respecting quoted strings
        tokens = tokenize(m.group(2))
        facts.setdefault(ftype, []).append(tokens)
    return facts


def tokenize(s: str) -> list[str]:
    """Split a Shen fact interior into tokens, keeping quoted strings intact."""
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


def collect_definitions(facts: dict) -> dict[str, str]:
    """Build {symbol: definition_text} from definition facts."""
    defs = {}
    for tokens in facts.get('definition', []):
        if len(tokens) >= 2:
            symbol = tokens[0]
            # Join remaining tokens as definition text, stripping quotes
            text = ' '.join(tokens[1:]).strip('"')
            defs[symbol] = text
    return defs


def collect_mechanism_defs(facts: dict, defs: dict) -> list[str]:
    """Collect all mechanism definition texts (by resolving mechanism symbol to its definition)."""
    texts = []
    for tokens in facts.get('mechanism', []):
        if len(tokens) >= 2:
            mech_symbol = tokens[1]  # [mechanism c1 mechsymbol]
            if mech_symbol in defs:
                texts.append(defs[mech_symbol])
    return texts


def main():
    facts_path = sys.argv[1] if len(sys.argv) > 1 else 'work/ai-facts.shen'

    if not Path(facts_path).exists():
        print(f"GAP-FIREWALL: {facts_path} not found — skipping")
        sys.exit(0)

    facts = parse_facts(facts_path)
    defs = collect_definitions(facts)
    mech_def_texts = collect_mechanism_defs(facts, defs)

    # Collect all definition texts (for symbol-level checks)
    all_def_texts = list(defs.values())

    # Find all ground-claims
    ground_claims = facts.get('ground-claim', [])
    if not ground_claims:
        sys.exit(0)

    disconnected = []
    for gc in ground_claims:
        if len(gc) < 3:
            continue
        gc_id = gc[0]
        source = gc[1]
        target = gc[2]

        # Check: does source appear in any mechanism definition?
        source_in_mech = any(source in t for t in mech_def_texts)
        target_in_mech = any(target in t for t in mech_def_texts)

        # Check: do source and target appear in the SAME mechanism definition?
        paired_in_mech = any(
            (source in t and target in t) for t in mech_def_texts
        )

        # Check: does source have a definition that mentions target?
        source_def = defs.get(source, '')
        target_in_source_def = target in source_def

        # Check: does target have a definition that mentions source?
        target_def = defs.get(target, '')
        source_in_target_def = source in target_def

        # Check: is there a bridging symbol? (symbol appears with source in one
        # definition/mechanism and with target in another)
        bridging = False
        for symbol in defs:
            if symbol in (source, target):
                continue
            sym_def = defs[symbol]
            appears_with_source = (
                source in sym_def or
                any(source in t and symbol in t for t in mech_def_texts)
            )
            appears_with_target = (
                target in sym_def or
                any(target in t and symbol in t for t in mech_def_texts)
            )
            if appears_with_source and appears_with_target:
                bridging = True
                break

        connected = (
            paired_in_mech or
            target_in_source_def or
            source_in_target_def or
            bridging
        )

        if not connected:
            disconnected.append((gc_id, source, target))

    if disconnected:
        print("GAP-FIREWALL: disconnected ground-claims detected")
        print("These ground-claims have sources and targets that never appear")
        print("together in any mechanism definition, nor is there a bridging symbol.")
        print()
        for gc_id, source, target in disconnected:
            print(f"  [{gc_id}] {source} -> {target}")
            print(f"       source '{source}' does not connect to target '{target}'")
            print(f"       in any mechanism definition")
            if source in defs:
                print(f"       source definition: {defs[source][:120]}...")
            if target in defs:
                print(f"       target definition: {defs[target][:120]}...")
            print()
        print("FIX: either write a mechanism whose definition explicitly connects")
        print("source and target, or remove the ground-claim and let Shen flag the gap.")
        sys.exit(1)
    else:
        print("GAP-FIREWALL: all ground-claims have connected source/target symbols")
        sys.exit(0)


if __name__ == '__main__':
    main()
