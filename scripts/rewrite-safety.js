#!/usr/bin/env node

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

const MODES = new Set(["structure_only", "rewrite_with_user_facts", "evidence_mode"]);
const STRUCTURE_ALLOWED_OPS = new Set([
  "keep",
  "split",
  "move",
  "rephrase",
  "surface-implicit-criterion",
  "insert-placeholder",
  "label",
  "mark-unresolved",
]);
const STRUCTURE_FORBIDDEN_OPS = new Set([
  "insert-fact",
  "insert-number",
  "insert-date",
  "insert-deadline",
  "insert-percentage",
  "insert-statistic",
  "insert-named-program",
  "insert-new-procedure",
  "insert-new-group",
  "insert-new-causal-mechanism",
  "strengthen-modality",
  "add-uniqueness-claim",
]);
const PROVENANCE_LABELS = new Set([
  "PRESERVED",
  "CLARIFIED",
  "REORDERED",
  "BRACKETED_GAP",
  "SURFACED_CRITERIA",
]);

const args = process.argv.slice(2);
const command = args[0] || "help";

try {
  if (command === "validate-patch") {
    const options = readOptions(args.slice(1));
    const result = validatePatchCommand(options);
    printJson(result);
    process.exit(result.accepted ? 0 : 1);
  } else if (command === "apply") {
    const options = readOptions(args.slice(1));
    const result = applyCommand(options);
    printJson(result);
    process.exit(result.accepted ? 0 : 1);
  } else if (command === "mutation") {
    const options = readOptions(args.slice(1));
    const result = mutationCommand(options);
    printMutationReport(result.report);
    process.exit(result.report.accepted ? 0 : 1);
  } else if (command === "run") {
    const options = readOptions(args.slice(1));
    const result = runCommand(options);
    process.stdout.write(result.reportText);
    process.exit(result.report.accepted ? 0 : 1);
  } else if (command === "test") {
    runSelfTests();
  } else {
    usage();
  }
} catch (error) {
  console.error(error.message || String(error));
  process.exit(1);
}

function usage() {
  process.stdout.write(`LogicBox rewrite safety

Commands:
  node scripts/rewrite-safety.js validate-patch --draft work/draft.txt --patch work/rewrite-patch.json
  node scripts/rewrite-safety.js apply --draft work/draft.txt --patch work/rewrite-patch.json --rewrite work/rewrite.md
  node scripts/rewrite-safety.js mutation --draft work/draft.txt --rewrite work/rewrite.md --patch work/rewrite-patch.json
  node scripts/rewrite-safety.js run --draft work/draft.txt --patch work/rewrite-patch.json --rewrite work/rewrite.md --report output/rewrite-report.md
  node scripts/rewrite-safety.js test
`);
}

function readOptions(argv) {
  const options = {};

  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];

    if (!item.startsWith("--")) {
      continue;
    }

    const key = item.slice(2);
    const next = argv[index + 1];

    if (!next || next.startsWith("--")) {
      options[key] = true;
    } else {
      options[key] = next;
      index += 1;
    }
  }

  return options;
}

function validatePatchCommand(options) {
  const draft = readText(required(options.draft, "--draft is required"));
  const patch = readPatch(required(options.patch, "--patch is required"));
  const validation = validatePatch(patch, draft);

  return {
    accepted: validation.errors.length === 0,
    mode: patch.mode || "structure_only",
    errors: validation.errors,
    warnings: validation.warnings,
  };
}

function applyCommand(options) {
  const draftPath = required(options.draft, "--draft is required");
  const patchPath = required(options.patch, "--patch is required");
  const rewritePath = required(options.rewrite, "--rewrite is required");
  const draft = readText(draftPath);
  const patch = readPatch(patchPath);
  const validation = validatePatch(patch, draft);

  if (validation.errors.length) {
    return {
      accepted: false,
      errors: validation.errors,
      warnings: validation.warnings,
    };
  }

  const rewrite = applyPatchToDraft(draft, patch);
  ensureParentDir(rewritePath);
  fs.writeFileSync(rewritePath, rewrite, "utf8");

  return {
    accepted: true,
    rewritePath,
    warnings: validation.warnings,
  };
}

function mutationCommand(options) {
  const draft = readText(required(options.draft, "--draft is required"));
  const rewrite = readText(required(options.rewrite, "--rewrite is required"));
  const patch = options.patch && fs.existsSync(options.patch) ? readPatch(options.patch) : null;
  const mode = options.mode || patch?.mode || "structure_only";
  const report = buildMutationReport(draft, rewrite, patch, mode);

  return { report };
}

function runCommand(options) {
  const draftPath = required(options.draft, "--draft is required");
  const patchPath = required(options.patch, "--patch is required");
  const rewritePath = required(options.rewrite, "--rewrite is required");
  const reportPath = required(options.report, "--report is required");
  const draft = readText(draftPath);
  const patch = readPatch(patchPath);
  const validation = validatePatch(patch, draft);
  let rewrite = "";
  let validationErrors = validation.errors.slice();

  if (!validationErrors.length) {
    rewrite = applyPatchToDraft(draft, patch);
  } else {
    rewrite = applyBestEffortPatch(draft, patch);
  }

  let report = buildMutationReport(draft, rewrite, patch, patch.mode || "structure_only");

  if (!report.accepted && (patch.mode || "structure_only") === "structure_only") {
    const repaired = repairRewriteWithPlaceholders(rewrite, report);
    rewrite = repaired.text;
    patch.gaps = mergeGaps(patch.gaps || [], repaired.gaps);
    report = buildMutationReport(draft, rewrite, patch, patch.mode || "structure_only");
    report.repaired = repaired.gaps.length > 0;
  }

  if (validationErrors.length) {
    report.patchErrors = validationErrors;
    report.accepted = false;
  }

  const reportText = formatFinalReport(rewrite, patch, report);
  ensureParentDir(rewritePath);
  ensureParentDir(reportPath);
  fs.writeFileSync(rewritePath, rewrite, "utf8");
  fs.writeFileSync(reportPath, reportText, "utf8");

  return { rewrite, report, reportText };
}

function validatePatch(patch, draft) {
  const errors = [];
  const warnings = [];
  const mode = patch.mode || "structure_only";

  if (!MODES.has(mode)) {
    errors.push(`Unknown rewrite mode: ${mode}`);
  }

  if (!Array.isArray(patch.operations)) {
    errors.push("Patch must include an operations array.");
    return { errors, warnings };
  }

  const gapIds = new Set((patch.gaps || []).map((gap) => gap.id));

  for (const operation of patch.operations) {
    const op = operation.op || operation.operation;

    if (!op) {
      errors.push("Patch operation is missing op.");
      continue;
    }

    if (mode === "structure_only") {
      if (STRUCTURE_FORBIDDEN_OPS.has(op)) {
        errors.push(`Forbidden operation in structure_only mode: ${op}`);
      }

      if (!STRUCTURE_ALLOWED_OPS.has(op)) {
        errors.push(`Operation is not allowed in structure_only mode: ${op}`);
      }
    }

    if (operation.text && op !== "keep") {
      const provenance = normalizeProvenance(operation.provenance);

      if (!provenance.length) {
        errors.push(`Changed operation ${op} is missing provenance labels.`);
      }

      for (const label of provenance) {
        if (!PROVENANCE_LABELS.has(label)) {
          errors.push(`Unknown provenance label ${label} on ${op}.`);
        }
      }
    }

    for (const gapId of normalizeGapRefs(operation)) {
      if (!gapIds.has(gapId)) {
        errors.push(`Operation references missing gap ${gapId}.`);
      }
    }
  }

  for (const gap of patch.gaps || []) {
    if (!gap.id || !gap.type) {
      errors.push("Every gap must include id and type.");
    }
  }

  const preview = applyBestEffortPatch(draft, patch);
  const mutation = buildMutationReport(draft, preview, patch, mode);

  if (mode === "structure_only" && !mutation.accepted) {
    for (const violation of mutation.violations) {
      errors.push(`Rewrite preflight blocked ${violation.kind}: ${violation.snippet}`);
    }
  }

  return { errors, warnings };
}

function applyPatchToDraft(draft, patch) {
  const sentences = splitSentences(draft);
  const sentenceMap = new Map(sentences.map((sentence, index) => [`s${index + 1}`, sentence]));
  const output = [];

  for (const operation of patch.operations || []) {
    const op = operation.op || operation.operation;

    if (op === "keep") {
      output.push(sentenceMap.get(operation.sentenceId) || "");
    } else if (op === "split") {
      output.push(...(operation.clauses || operation.texts || []));
    } else if (op === "rephrase" || op === "surface-implicit-criterion") {
      output.push(operation.text || "");
    } else if (op === "insert-placeholder") {
      output.push(formatStandalonePlaceholder(operation.gapId, patch));
    }
  }

  return joinSentences(output.filter(Boolean));
}

function applyBestEffortPatch(draft, patch) {
  try {
    return applyPatchToDraft(draft, patch);
  } catch (error) {
    return draft;
  }
}

function buildMutationReport(draft, rewrite, patch, mode) {
  const original = analyzeText(draft);
  const candidate = analyzeText(rewrite);
  const nonPlaceholderRewrite = substitutePlaceholdersWithGapSubjects(rewrite, patch);
  const nonPlaceholderCandidate = analyzeText(nonPlaceholderRewrite);
  const violations = [];

  addNewItems(violations, "added-threshold", nonPlaceholderCandidate.thresholds, original.thresholds);
  addNewItems(violations, "added-percentage", nonPlaceholderCandidate.percentages, original.percentages);
  addNewItems(violations, "added-named-program", nonPlaceholderCandidate.namedPrograms, original.namedPrograms);
  addNewItems(violations, "added-deadline", nonPlaceholderCandidate.deadlines, original.deadlines);
  addNewItems(violations, "added-named-entity", nonPlaceholderCandidate.namedEntities, original.namedEntities);
  addNewItems(violations, "added-comparison-claim", nonPlaceholderCandidate.comparisons, original.comparisons);
  addNewItems(violations, "added-empirical-claim", nonPlaceholderCandidate.empiricalClaims, original.empiricalClaims);
  addNewItems(violations, "added-procedure", nonPlaceholderCandidate.procedures, original.procedures);
  addNewItems(violations, "added-group", nonPlaceholderCandidate.groups, original.groups);
  addNewItems(violations, "scope-changed", nonPlaceholderCandidate.scopes, original.scopes);
  addNewItems(violations, "added-uniqueness-claim", nonPlaceholderCandidate.uniqueness, original.uniqueness);

  if (modalityStrength(candidate.modalities) > modalityStrength(original.modalities)) {
    violations.push({ kind: "modality-strengthened", snippet: strongestModality(candidate.modalities) });
  }

  const objectionsRemoved = detectRemovedObjections(draft, rewrite);

  for (const objection of objectionsRemoved) {
    violations.push({ kind: "objection-removed", snippet: objection });
  }

  const placeholders = extractPlaceholders(rewrite);
  const modeAccepted = mode !== "structure_only" || violations.length === 0;

  return {
    mode,
    accepted: modeAccepted,
    repaired: false,
    placeholders,
    violations,
    checks: {
      newEvidenceAdded: yesNo(hasKind(violations, "added-empirical-claim")),
      newThresholdsAdded: yesNo(hasKind(violations, "added-threshold")),
      newPercentagesAdded: yesNo(hasKind(violations, "added-percentage")),
      newNamedProgramsAdded: yesNo(hasKind(violations, "added-named-program")),
      newNamedEntitiesAdded: yesNo(hasKind(violations, "added-named-entity")),
      newDatesDeadlinesAdded: yesNo(hasKind(violations, "added-deadline")),
      newProceduresAdded: yesNo(hasKind(violations, "added-procedure")),
      newGroupsAdded: yesNo(hasKind(violations, "added-group")),
      scopeChanged: yesNo(hasKind(violations, "scope-changed")),
      modalityStrengthened: yesNo(hasKind(violations, "modality-strengthened")),
      conclusionStrengthened: yesNo(
        hasKind(violations, "added-uniqueness-claim") || hasKind(violations, "modality-strengthened"),
      ),
      objectionsRemoved: yesNo(hasKind(violations, "objection-removed")),
    },
  };
}

function analyzeText(text) {
  const clean = text || "";

  return {
    thresholds: unique(matches(clean, [
      /\b\d+\s+or\s+more\s+\w+/gi,
      /\bfewer\s+than\s+\d+\s+\w+/gi,
      /\bmore\s+than\s+\d+\s+\w+/gi,
      /\bless\s+than\s+\d+\s+\w+/gi,
      /\bstatistically significant\b/gi,
      /\bsafety threshold\b/gi,
    ])),
    percentages: unique(matches(clean, [/\b\d+(?:\.\d+)?\s*%/g, /\b\d+(?:\.\d+)?\s+percent\b/gi])),
    namedPrograms: unique(matches(clean, [
      /\b[A-Z][A-Za-z-]+(?:\s+[A-Z][A-Za-z-]+)*\s+(?:Program|Initiative|Fund|Grant|Subsidy|Pilot|Act|Code)\b/g,
    ])),
    deadlines: unique(matches(clean, [
      /\bbefore the next [a-z-]+ season\b/gi,
      /\bwithin\s+\d+\s+(?:days|weeks|months|years)\b/gi,
      /\blast year\b/gi,
      /\bnext year\b/gi,
      /\bby\s+\[[^\]]+\]/gi,
      /\bby\s+(?:january|february|march|april|may|june|july|august|september|october|november|december)\b[^\.,;]*/gi,
    ])),
    namedEntities: unique(extractNamedEntities(clean)),
    comparisons: unique(matches(clean, [
      /\b\w+\s+kills\s+more\s+[^.,;]+/gi,
      /\bmore\s+\w+\s+than\s+[^.,;]+/gi,
      /\bhigher\s+[^.,;]+/gi,
      /\blower\s+[^.,;]+/gi,
      /\brecord-high\s+[^.,;]+/gi,
      /\bcompared?\s+(?:with|to)\s+[^.,;]+/gi,
    ])),
    empiricalClaims: unique(matches(clean, [
      /\brecorded\s+[^.,;]+/gi,
      /\brecord-high\s+[^.,;]+/gi,
      /\bdata\s+(?:show|shows|showed)\s+[^.,;]+/gi,
      /\bstudies\s+(?:show|shows|showed)\s+[^.,;]+/gi,
      /\bevidence\s+(?:shows|suggests)\s+[^.,;]+/gi,
      /\bheat kills\s+[^.,;]+/gi,
    ])),
    procedures: unique(matches(clean, [
      /\bannual audit\b/gi,
      /\binvestigate within\s+\d+\s+(?:days|weeks|months)\b/gi,
      /\bfindings made public\b/gi,
      /\btriggering early-warning responses\b/gi,
      /\bcover(?:ing)? up to\s+[^.,;]+/gi,
      /\bshould cover a comparable percentage\b/gi,
    ])),
    groups: unique(matches(clean, [
      /\bfewer than\s+\d+\s+units\b/gi,
      /\b\d+\s+or\s+more\s+units\b/gi,
      /\bprotected group\b/gi,
    ])),
    scopes: unique(matches(clean, [
      /\b(?:all|every|any|no|most)\s+[a-z][a-z-]*(?:\s+[a-z][a-z-]*){0,4}\b/gi,
      /\b(?:only if|only when|except when|except for)\s+[^.,;]+/gi,
      /\bfor\s+(?:all|every|any|no|most)\s+[^.,;]+/gi,
    ])),
    uniqueness: unique(matches(clean, [/\bonly\b/gi, /\balways\b/gi, /\bnever\b/gi, /\bthe only\s+[^.,;]+/gi])),
    modalities: unique(matches(clean, [/\bshould\b/gi, /\bmust\b/gi, /\brequire\b/gi, /\bnecessary\b/gi, /\bcould\b/gi, /\bmay\b/gi])),
  };
}

function repairRewriteWithPlaceholders(text, report) {
  let repaired = text;
  const gaps = [];
  let counter = 1;

  for (const violation of report.violations) {
    const gapId = `G_AUTO_${counter}`;
    counter += 1;
    const gap = gapForViolation(gapId, violation);
    gaps.push(gap);

    if (violation.snippet) {
      repaired = replaceOnce(repaired, violation.snippet, `[${gap.id}: ${gap.prompt}]`);
    }
  }

  return { text: repaired, gaps };
}

function gapForViolation(id, violation) {
  const map = {
    "added-threshold": ["threshold-needed", "define threshold"],
    "added-percentage": ["funding-needed", "define percentage"],
    "added-named-program": ["definition-needed", "identify existing named program, if any"],
    "added-deadline": ["procedure-needed", "define timeline"],
    "added-named-entity": ["definition-needed", "identify existing named entity, if any"],
    "added-comparison-claim": ["evidence-needed", "add comparative evidence, if relevant"],
    "added-empirical-claim": ["evidence-needed", "add evidence"],
    "added-procedure": ["procedure-needed", "define procedure"],
    "added-group": ["definition-needed", "define group/category"],
    "scope-changed": ["definition-needed", "clarify scope"],
    "added-uniqueness-claim": ["value-criteria-needed", "clarify whether this is unique or merely direct"],
    "modality-strengthened": ["value-criteria-needed", "clarify modality"],
    "objection-removed": ["procedure-needed", "restore or address objection"],
  };
  const [type, prompt] = map[violation.kind] || ["definition-needed", "clarify missing information"];

  return {
    id,
    type,
    subject: violation.snippet,
    prompt,
  };
}

function formatFinalReport(rewrite, patch, report) {
  const gaps = patch.gaps || [];
  const lines = [];

  lines.push("## Structure-only rewrite");
  lines.push("");
  lines.push(rewrite.trim() || "(no rewrite produced)");
  lines.push("");
  lines.push("## Gap list");
  lines.push("");

  if (!gaps.length && !report.placeholders.length) {
    lines.push("No placeholders.");
  } else {
    for (const gap of gaps) {
      lines.push(`${gap.id}: ${gap.prompt || gap.description || `${gap.type} ${gap.subject || ""}`.trim()}`);
    }
  }

  lines.push("");
  lines.push("## Mutation report");
  lines.push("");
  lines.push(formatMutationReport(report));

  return `${lines.join("\n")}\n`;
}

function printMutationReport(report) {
  process.stdout.write(`${formatMutationReport(report)}\n`);
}

function formatMutationReport(report) {
  const lines = [];

  lines.push(`New evidence added: ${report.checks.newEvidenceAdded}`);
  lines.push(`New thresholds added: ${report.checks.newThresholdsAdded}${placeholderSuffix(report, "threshold")}`);
  lines.push(`New percentages added: ${report.checks.newPercentagesAdded}${placeholderSuffix(report, "percentage")}`);
  lines.push(`New named programs added: ${report.checks.newNamedProgramsAdded}`);
  lines.push(`New named entities added: ${report.checks.newNamedEntitiesAdded}`);
  lines.push(`New dates/deadlines added: ${report.checks.newDatesDeadlinesAdded}${placeholderSuffix(report, "timeline")}`);
  lines.push(`New procedures added: ${report.checks.newProceduresAdded}${placeholderSuffix(report, "procedure")}`);
  lines.push(`New groups added: ${report.checks.newGroupsAdded}`);
  lines.push(`Scope changed: ${report.checks.scopeChanged}`);
  lines.push(`Modality strengthened: ${report.checks.modalityStrengthened}`);
  lines.push(`Conclusion strengthened: ${report.checks.conclusionStrengthened}`);
  lines.push(`Objections removed: ${report.checks.objectionsRemoved}`);
  lines.push(`Placeholders inserted: ${report.placeholders.length ? report.placeholders.join(", ") : "none"}`);

  for (const violation of report.violations) {
    lines.push(`Mutation violation: ${violation.kind} "${violation.snippet}"`);
  }

  lines.push(`Accepted: ${report.accepted ? "yes" : "no"}`);
  return lines.join("\n");
}

function placeholderSuffix(report, keyword) {
  return report.placeholders.some((item) => item.toLowerCase().includes(keyword)) ? ", only placeholders" : "";
}

function splitSentences(text) {
  return (text || "")
    .replace(/\s+/g, " ")
    .trim()
    .match(/[^.!?]+[.!?]+|[^.!?]+$/g)
    ?.map((item) => item.trim()) || [];
}

function joinSentences(sentences) {
  return sentences.join("\n\n").replace(/\n{3,}/g, "\n\n").trim() + "\n";
}

function normalizeProvenance(value) {
  if (Array.isArray(value)) {
    return value;
  }

  if (typeof value === "string" && value.trim()) {
    return value.split(/[,+\s]+/).filter(Boolean);
  }

  return [];
}

function normalizeGapRefs(operation) {
  const refs = [];

  if (operation.gapId) {
    refs.push(operation.gapId);
  }

  if (Array.isArray(operation.gaps)) {
    refs.push(...operation.gaps);
  }

  return refs;
}

function formatStandalonePlaceholder(gapId, patch) {
  const gap = (patch.gaps || []).find((item) => item.id === gapId);
  const prompt = gap?.prompt || gap?.description || "fill missing information";
  return `[${gapId}: ${prompt}]`;
}

function extractPlaceholders(text) {
  return unique(matches(text, [/\[G[A-Z0-9_-]*:\s*[^\]]+\]/gi]));
}

function stripPlaceholders(text) {
  return (text || "").replace(/\[G[A-Z0-9_-]*:\s*[^\]]+\]/gi, "");
}

function substitutePlaceholdersWithGapSubjects(text, patch) {
  const gaps = new Map((patch?.gaps || []).map((gap) => [gap.id, gap.subject || ""]));

  return (text || "").replace(/\[(G[A-Z0-9_-]*):\s*[^\]]+\]/gi, (_match, gapId) => gaps.get(gapId) || "");
}

function addNewItems(violations, kind, candidateItems, originalItems) {
  const original = new Set(originalItems.map(canonical));

  for (const item of candidateItems) {
    if (!original.has(canonical(item))) {
      violations.push({ kind, snippet: item });
    }
  }
}

function hasKind(reportOrViolations, kind) {
  const violations = Array.isArray(reportOrViolations) ? reportOrViolations : reportOrViolations.violations;
  return violations.some((item) => item.kind === kind);
}

function yesNo(value) {
  return value ? "yes" : "no";
}

function modalityStrength(modalities) {
  const joined = modalities.map((item) => item.toLowerCase()).join(" ");

  if (/\bmust\b|\bnecessary\b/.test(joined)) {
    return 3;
  }

  if (/\bshould\b|\brequire\b/.test(joined)) {
    return 2;
  }

  if (/\bcould\b|\bmay\b/.test(joined)) {
    return 1;
  }

  return 0;
}

function strongestModality(modalities) {
  return modalities.find((item) => /\bmust\b|\bnecessary\b/i.test(item)) || modalities[0] || "";
}

function detectRemovedObjections(draft, rewrite) {
  const rewriteCanon = canonical(rewrite);

  return splitSentences(draft).filter((sentence) => {
    if (!/\b(worry|argue|concern|object|however|but|should not|must not)\b/i.test(sentence)) {
      return false;
    }

    const important = canonical(sentence)
      .split(" ")
      .filter((word) => word.length > 4)
      .slice(0, 5);

    return important.length >= 2 && !important.some((word) => rewriteCanon.includes(word));
  });
}

function extractNamedEntities(text) {
  const results = [];
  const pattern = /\b(?:[A-Z][a-z]+(?:\s+|$)){2,}(?:Program|Department|University|Office|Agency|System|Act|Code)?/g;
  let match;

  while ((match = pattern.exec(text || ""))) {
    const value = match[0].trim();

    if (!/^(The|Some|Other|Most|Therefore|Extreme)\b/.test(value)) {
      results.push(value);
    }
  }

  return results;
}

function matches(text, patterns) {
  const results = [];

  for (const pattern of patterns) {
    let match;

    while ((match = pattern.exec(text || ""))) {
      results.push(match[0].trim());
    }
  }

  return results;
}

function unique(items) {
  return Array.from(new Set(items.filter(Boolean)));
}

function canonical(value) {
  return String(value || "")
    .toLowerCase()
    .replace(/[^a-z0-9%]+/g, " ")
    .trim()
    .replace(/\s+/g, " ");
}

function replaceOnce(text, search, replacement) {
  const index = text.indexOf(search);

  if (index === -1) {
    return text;
  }

  return `${text.slice(0, index)}${replacement}${text.slice(index + search.length)}`;
}

function mergeGaps(existing, additions) {
  const byId = new Map();

  for (const gap of existing) {
    byId.set(gap.id, gap);
  }

  for (const gap of additions) {
    byId.set(gap.id, gap);
  }

  return Array.from(byId.values());
}

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function readPatch(filePath) {
  return JSON.parse(readText(filePath));
}

function required(value, message) {
  if (!value) {
    throw new Error(message);
  }

  return value;
}

function ensureParentDir(filePath) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

function printJson(value) {
  process.stdout.write(`${JSON.stringify(value, null, 2)}\n`);
}

function runSelfTests() {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "logicbox-rewrite-test."));
  const draftPath = path.join(tempDir, "draft.txt");
  const validPatchPath = path.join(tempDir, "valid.json");
  const invalidPatchPath = path.join(tempDir, "invalid.json");
  const rewritePath = path.join(tempDir, "rewrite.md");
  const reportPath = path.join(tempDir, "report.md");
  const draft = "The city should require large apartment buildings to install smart cooling systems.";

  fs.writeFileSync(draftPath, draft, "utf8");
  fs.writeFileSync(
    validPatchPath,
    JSON.stringify(
      {
        mode: "structure_only",
        gaps: [
          {
            id: "G1",
            type: "definition-needed",
            subject: "large apartment buildings",
            prompt: "define which buildings count as large",
          },
        ],
        operations: [
          {
            op: "rephrase",
            sentenceId: "s1",
            provenance: ["CLARIFIED", "BRACKETED_GAP"],
            gaps: ["G1"],
            text:
              "The city should require large apartment buildings — [G1: define which buildings count as large] — to install smart cooling systems.",
          },
        ],
      },
      null,
      2,
    ),
    "utf8",
  );
  fs.writeFileSync(
    invalidPatchPath,
    JSON.stringify(
      {
        mode: "structure_only",
        operations: [
          {
            op: "rephrase",
            sentenceId: "s1",
            provenance: ["CLARIFIED"],
            text:
              "The city should require apartment buildings with 20 or more units to install smart cooling systems.",
          },
        ],
      },
      null,
      2,
    ),
    "utf8",
  );

  const valid = runCommand({ draft: draftPath, patch: validPatchPath, rewrite: rewritePath, report: reportPath });

  assert(valid.report.accepted, "valid structure-only rewrite should be accepted");
  assert(valid.rewrite.includes("[G1:"), "valid rewrite should keep placeholder");

  const invalid = validatePatchCommand({ draft: draftPath, patch: invalidPatchPath });

  assert(!invalid.accepted, "invalid threshold patch should be blocked");
  assert(
    invalid.errors.some((error) => error.includes("added-threshold") && error.includes("20 or more units")),
    "invalid patch should report added threshold",
  );

  fs.writeFileSync(
    invalidPatchPath,
    JSON.stringify(
      {
        mode: "structure_only",
        operations: [
          {
            op: "rephrase",
            sentenceId: "s1",
            provenance: ["CLARIFIED"],
            text:
              "The city should require large apartment buildings to install smart cooling systems through the Fire Code Assistance Program with a 70% subsidy.",
          },
        ],
      },
      null,
      2,
    ),
    "utf8",
  );
  const namedProgram = validatePatchCommand({ draft: draftPath, patch: invalidPatchPath });

  assert(!namedProgram.accepted, "named program and percentage patch should be blocked");
  assert(
    namedProgram.errors.some((error) => error.includes("added-named-program") && error.includes("Fire Code Assistance Program")),
    "invalid patch should report added named program",
  );
  assert(
    namedProgram.errors.some((error) => error.includes("added-percentage") && error.includes("70%")),
    "invalid patch should report added percentage",
  );

  fs.writeFileSync(
    rewritePath,
    "The city should require apartment buildings with 20 or more units to install smart cooling systems.",
    "utf8",
  );
  const mutation = mutationCommand({ draft: draftPath, rewrite: rewritePath, mode: "structure_only" });

  assert(!mutation.report.accepted, "free-form invalid rewrite should fail mutation");
  assert(hasKind(mutation.report, "added-threshold"), "mutation should flag added threshold");

  process.stdout.write("rewrite-safety tests passed\n");
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}
