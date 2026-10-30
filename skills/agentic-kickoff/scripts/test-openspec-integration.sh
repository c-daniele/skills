#!/usr/bin/env bash
# Verify the external-task schema contract against the installed OpenSpec CLI.
# All projects and board mutations are disposable fixtures; no install is run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

if ! command -v openspec >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
    printf 'SKIP: openspec/node not installed; OpenSpec integration test not run.\n'
    exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
project="${TMP}/project"
mkdir -p "${project}/openspec/specs" "${project}/openspec/changes" "${project}/docs"
cp -R "${SKILL_DIR}/assets/openspec" "${project}/openspec/schemas"
cp "${SKILL_DIR}/assets/templates/openspec-config.yaml.tmpl" "${project}/openspec/config.yaml"
printf '# Fixture workflow\nBacklog owns execution and evidence.\n' > "${project}/docs/spec-workflow.md"

check_apply() {
    local file="$1" expected="$2" missing="${3:-}"
    node - "$file" "$expected" "$missing" <<'JS'
const fs = require('node:fs');
const assert = require('node:assert/strict');
const [file, expected, missing] = process.argv.slice(2);
const result = JSON.parse(fs.readFileSync(file, 'utf8'));
assert.equal(result.state, expected);
assert.deepEqual(result.tasks, []);
if (missing) assert.ok(result.missingArtifacts.includes(missing));
if (expected === 'ready') {
  assert.match(result.instruction, /Backlog/);
  assert.match(result.instruction, /completion check/);
  assert.equal(result.progress.total, 0);
}
JS
}

(
    cd "$project"
    openspec schema validate backlog-lean > "${TMP}/lean-schema.txt"
    openspec schema validate backlog-design > "${TMP}/design-schema.txt"

    # A greenfield delta is not a baseline until archive. No tasks.md is needed.
    openspec new change add-export-contract --schema backlog-lean > "${TMP}/new-lean.txt"
    openspec instructions apply --change add-export-contract --json > "${TMP}/blocked.json"
    check_apply "${TMP}/blocked.json" blocked specs
    openspec instructions specs --change add-export-contract --json > "${TMP}/spec-instructions.json"
    grep -q 'Requirement:' "${TMP}/spec-instructions.json"

    cat > openspec/changes/add-export-contract/proposal.md <<'EOF'
## Why
Account owners need an export contract with predictable access boundaries.

## What Changes
- Add account-scoped export access and missing-export behavior.

## Capabilities
### New Capabilities
- exports: retrieve an account-owned export.
### Modified Capabilities
None.
EOF
    mkdir -p openspec/changes/add-export-contract/specs/exports
    cat > openspec/changes/add-export-contract/specs/exports/spec.md <<'EOF'
## ADDED Requirements

### Requirement: EXP-001 Account-scoped export
The system SHALL return an export only to its owning account.

#### Scenario: Owner retrieves an export
- **WHEN** the owner requests an available export
- **THEN** the export is returned

#### Scenario: Other account requests an export
- **WHEN** another account requests the export
- **THEN** access is denied without returning export data

### Requirement: EXP-002 Missing export
The system SHALL report when the requested export does not exist.

#### Scenario: Unknown export
- **WHEN** an account requests an unknown export
- **THEN** the result reports that the export was not found
EOF
    openspec validate add-export-contract --type change --strict > "${TMP}/lean-validation.txt"
    openspec instructions apply --change add-export-contract --json > "${TMP}/ready-lean.json"
    check_apply "${TMP}/ready-lean.json" ready
    [ ! -e openspec/changes/add-export-contract/tasks.md ]
    [ ! -e openspec/specs/exports/spec.md ]

    # Exercise the real Backlog label/reference join when the CLI is available.
    task_id=''
    active_ref='openspec/changes/add-export-contract/specs/exports/spec.md'
    if command -v backlog >/dev/null 2>&1; then
        BACKLOG_CWD="$PWD" backlog init 'OpenSpec Fixture' --defaults \
            --integration-mode none --backlog-dir work-items --config-location root --no-git > "${TMP}/backlog-init.txt"
        [ -d work-items/tasks ]
        [ ! -e .backlog ]
        BACKLOG_CWD="$PWD" backlog config get projectName | grep -q 'OpenSpec Fixture'
        output="$(BACKLOG_CWD="$PWD" backlog task create 'Verify export contract archival' \
            --type task --priority Medium --status 'To Do' --labels change-add-export-contract \
            -d 'Change: add-export-contract. Requirements: EXP-001 and EXP-002.' \
            --ref "$active_ref" --ac 'The archived main spec retains both access scenarios and the missing-export requirement.' --plain)"
        task_id="$(printf '%s\n' "$output" | sed -n 's/^Task \([^ ]*\) -.*/\1/p' | head -n 1)"
        [ -n "$task_id" ]
        BACKLOG_CWD="$PWD" backlog task list --labels change-add-export-contract --json > "${TMP}/linked-tasks.json"
        grep -qF "$task_id" "${TMP}/linked-tasks.json"
    fi

    # CLI archive is intentionally independent of the external board. This is
    # a contract test, not the delivery workflow's approval/completion gate.
    openspec archive add-export-contract --yes > "${TMP}/archive-lean.txt"
    [ ! -d openspec/changes/add-export-contract ]
    [ -f openspec/specs/exports/spec.md ]
    archive_path="$(find openspec/changes/archive -mindepth 1 -maxdepth 1 -type d -name '*-add-export-contract')"
    [ -n "$archive_path" ]
    [ -f "${archive_path}/specs/exports/spec.md" ]

    # OpenSpec may scaffold a Purpose placeholder on first archive. Supply the
    # already approved fixture purpose, as required by the documented workflow.
    node - <<'JS'
const fs = require('node:fs');
const assert = require('node:assert/strict');
const file = 'openspec/specs/exports/spec.md';
let spec = fs.readFileSync(file, 'utf8');
for (const text of ['EXP-001', 'EXP-002', 'Owner retrieves an export', 'Other account requests an export']) {
  assert.ok(spec.includes(text), `Missing archived behavior: ${text}`);
}
spec = spec.replace(/^## Purpose\r?\n[\s\S]*?(?=^## )/m,
  '## Purpose\n\nAllow account owners to retrieve exports within an explicit access boundary.\n\n');
fs.writeFileSync(file, spec);
JS
    openspec validate exports --type spec --strict > "${TMP}/baseline-validation.txt"

    if [ -n "$task_id" ]; then
        archived_ref="${archive_path}/specs/exports/spec.md"
        BACKLOG_CWD="$PWD" backlog task edit "$task_id" --remove-ref "$active_ref" \
            --add-ref "$archived_ref" --add-ref openspec/specs/exports/spec.md \
            --check-ac 1 --status Done \
            --final-summary 'Verified archive output, both EXP-001 scenarios, EXP-002 preservation and strict main-spec validation.' > "${TMP}/task-edit.txt"
        BACKLOG_CWD="$PWD" backlog task view "$task_id" --json > "${TMP}/task-final.json"
        grep -qF "$archived_ref" "${TMP}/task-final.json"
        grep -q '"status": "Done"' "${TMP}/task-final.json"
        if grep -qF "$active_ref" "${TMP}/task-final.json"; then
            printf 'FAIL: task still references the moved change.\n' >&2
            exit 1
        fi
    fi

    # Brownfield MODIFIED must preserve surviving scenarios and unrelated rules.
    openspec new change add-export-expiry --schema backlog-design > "${TMP}/new-design.txt"
    cat > openspec/changes/add-export-expiry/proposal.md <<'EOF'
## Why
Account owners need an explicit response when an export expires.

## What Changes
- Extend the existing export contract with expiry behavior.

## Capabilities
### New Capabilities
None.
### Modified Capabilities
- exports: report an expired export without returning its data.
EOF
    mkdir -p openspec/changes/add-export-expiry/specs/exports
    cat > openspec/changes/add-export-expiry/specs/exports/spec.md <<'EOF'
## MODIFIED Requirements

### Requirement: EXP-001 Account-scoped export
The system SHALL return an unexpired export only to its owning account and report expiry to the owner otherwise.

#### Scenario: Owner retrieves an export
- **WHEN** the owner requests an available unexpired export
- **THEN** the export is returned

#### Scenario: Other account requests an export
- **WHEN** another account requests the export
- **THEN** access is denied without returning export data

#### Scenario: Owner requests an expired export
- **WHEN** the owner requests an expired export
- **THEN** expiry is reported without returning export data
EOF
    openspec instructions apply --change add-export-expiry --json > "${TMP}/design-blocked.json"
    check_apply "${TMP}/design-blocked.json" blocked design
    cat > openspec/changes/add-export-expiry/design.md <<'EOF'
## Technical Approach
Inspect expiry after the existing ownership check so the added response cannot disclose another account's export state.
EOF
    openspec validate add-export-expiry --type change --strict > "${TMP}/design-validation.txt"
    openspec instructions apply --change add-export-expiry --json > "${TMP}/ready-design.json"
    check_apply "${TMP}/ready-design.json" ready
    [ ! -e openspec/changes/add-export-expiry/tasks.md ]
    openspec archive add-export-expiry --yes > "${TMP}/archive-design.txt"
    [ ! -d openspec/changes/add-export-expiry ]
    openspec validate exports --type spec --strict > "${TMP}/modified-validation.txt"
    node - <<'JS'
const fs = require('node:fs');
const assert = require('node:assert/strict');
const spec = fs.readFileSync('openspec/specs/exports/spec.md', 'utf8');
assert.equal((spec.match(/^### Requirement:/gm) || []).length, 2);
assert.equal((spec.match(/^#### Scenario:/gm) || []).length, 4);
assert.match(spec, /Owner retrieves an export/);
assert.match(spec, /Other account requests an export/);
assert.match(spec, /Owner requests an expired export/);
assert.match(spec, /EXP-002 Missing export/);
assert.match(spec, /Unknown export/);
JS
)

printf 'OK: OpenSpec %s validates both schemas, external-task readiness and ADDED/MODIFIED archival.\n' "$(openspec --version)"
