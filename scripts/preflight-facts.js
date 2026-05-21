#!/usr/bin/env node

const fs = require("node:fs");

const compactFactPredicates = new Set([
  "claim",
  "ground-claim",
  "conclusion",
  "mechanism",
  "outcome",
  "risk",
  "claim-content",
  "rewrite-claim",
]);

const compressedPrefixes = [
  "better",
  "worse",
  "more",
  "less",
  "increased",
  "increase",
  "reduced",
  "reduce",
  "decreased",
  "decrease",
  "improved",
  "improve",
  "fairer",
  "weaker",
  "stronger",
  "high",
  "low",
  "lesser",
];

const compressedWords = [
  "reform",
  "outcome",
  "outcomes",
  "solution",
  "program",
  "policy",
  "choice",
  "ban",
  "monitoring",
  "productivity",
  "methodology",
  "methodologies",
  "scalability",
  "adaptability",
  "student-centered",
  "does-not",
  "not-hurt",
];

const standaloneValueWords = new Set([
  "fairness",
  "justice",
  "privacy",
  "trust",
  "discipline",
  "practicality",
  "responsibility",
  "necessity",
]);

const files = process.argv.slice(2);
const markers = {
  compound: new Map(),
  decomposition: new Map(),
  valueCriteria: new Map(),
};

for (const file of files) {
  if (!file || !fs.existsSync(file)) {
    continue;
  }

  validateFacts(fs.readFileSync(file, "utf8"), markers);
}

const facts = [
  ...Array.from(markers.compound.keys()).map((atom) => `[compound-domain-atom ${atom}]`),
  ...Array.from(markers.decomposition.keys()).map((atom) => `[decomposition-candidate ${atom}]`),
  ...Array.from(markers.valueCriteria.entries()).map(([atom, value]) => `[value-criteria-candidate ${atom} ${value}]`),
];

if (!facts.length) {
  process.stdout.write("(set *facts* (value *facts*))\n");
} else {
  process.stdout.write("(set *facts*\n");
  process.stdout.write("  (append (value *facts*)\n");
  process.stdout.write("    [\n");
  for (const fact of facts) {
    process.stdout.write(`      ${fact}\n`);
  }
  process.stdout.write("    ]))\n");
}

function validateFacts(facts, markers) {
  for (const fact of parseBracketFacts(facts)) {
    const [predicate, ...args] = tokenizeFact(fact);

    if (!predicate) {
      continue;
    }

    if (predicate === "term" && shouldClassifyAtom(args[0])) {
      markAtom(args[0], markers);
      continue;
    }

    if (compactFactPredicates.has(predicate)) {
      for (const atom of compactPredicateAtoms(predicate, args)) {
        if (shouldClassifyAtom(atom)) {
          markAtom(atom, markers);
        }
      }
    }
  }
}

function markAtom(atom, markers) {
  const valueType = valueCriteriaType(atom);

  if (valueType) {
    markers.valueCriteria.set(atom, valueType);
    return;
  }

  if (needsDecomposition(atom)) {
    markers.decomposition.set(atom, true);
    return;
  }

  markers.compound.set(atom, true);
}

function shouldClassifyAtom(atom) {
  return Boolean(valueCriteriaType(atom) || needsDecomposition(atom) || isCompressedDomainAtom(atom));
}

function compactPredicateAtoms(predicate, args) {
  if (predicate === "claim" || predicate === "rewrite-claim") {
    return args.slice(2);
  }

  if (predicate === "ground-claim") {
    return args.slice(1);
  }

  if (predicate === "conclusion") {
    return args.slice(1);
  }

  if (predicate === "mechanism" || predicate === "outcome" || predicate === "risk" || predicate === "claim-content") {
    return args.slice(1);
  }

  return [];
}

function parseBracketFacts(facts) {
  return stripFactStrings(facts).match(/\[[^\[\]\n]+\]/g) || [];
}

function stripFactStrings(value) {
  let output = "";
  let inString = false;
  let escaped = false;

  for (const char of value) {
    if (escaped) {
      output += " ";
      escaped = false;
      continue;
    }

    if (char === "\\") {
      output += " ";
      escaped = true;
      continue;
    }

    if (char === '"') {
      output += " ";
      inString = !inString;
      continue;
    }

    output += inString ? " " : char;
  }

  return output;
}

function tokenizeFact(fact) {
  return fact
    .replace(/^\[/, "")
    .replace(/\]$/, "")
    .trim()
    .split(/\s+/)
    .filter(Boolean);
}

function isCompressedDomainAtom(atom) {
  const value = typeof atom === "string" ? atom.toLowerCase() : "";

  if (!value || value === "unknown" || isLikelyIdentifier(value)) {
    return false;
  }

  if (standaloneValueWords.has(value)) {
    return true;
  }

  if (!value.includes("-")) {
    return false;
  }

  const parts = value.split("-").filter(Boolean);

  if (parts.length < 2) {
    return false;
  }

  if (compressedPrefixes.includes(parts[0])) {
    return true;
  }

  return compressedWords.some((word) => value === word || value.includes(word));
}

function needsDecomposition(atom) {
  const value = typeof atom === "string" ? atom.toLowerCase() : "";

  return Boolean(
    value === "diagnosis" ||
      value.includes("diagnose") ||
      value.includes("patients-told") ||
      value.includes("told") ||
      value.includes("notify") ||
      value.includes("override") ||
      value.includes("final-treatment-decision") ||
      value.includes("final-admissions-decision") ||
      value.includes("decision") ||
      value.includes("rank-by") ||
      value.includes("infer-race") ||
      value.includes("infer-income"),
  );
}

function valueCriteriaType(atom) {
  const value = typeof atom === "string" ? atom.toLowerCase() : "";

  if (value === "fair" || value === "fairness" || value.endsWith("-is-fair") || value.includes("-fair-")) {
    return "fairness";
  }

  if (value === "safe" || value === "safety" || value.endsWith("-is-safe") || value.includes("-safe-")) {
    return "safety";
  }

  if (
    value === "necessary" ||
    value === "necessity" ||
    value.includes("necessary-improvement") ||
    value.endsWith("-is-necessary")
  ) {
    return "necessity";
  }

  if (value === "efficient" || value === "efficiency" || value.endsWith("-is-efficient")) {
    return "efficiency";
  }

  if (
    value === "responsible" ||
    value === "responsibility" ||
    value.endsWith("-is-responsible") ||
    value.includes("responsible")
  ) {
    return "responsibility";
  }

  if (value === "practical" || value === "practicality" || value.endsWith("-is-practical")) {
    return "practicality";
  }

  return "";
}

function isLikelyIdentifier(value) {
  return /^[a-z]+[0-9]+(?:-[a-z]+)?$/.test(value) || /^draft-[0-9]+$/.test(value);
}
