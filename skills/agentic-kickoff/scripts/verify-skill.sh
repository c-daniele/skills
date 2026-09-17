#!/usr/bin/env bash
# verify-skill.sh - structural verification for the agentic-kickoff Agent Skill.
#
# Checks Agent Skills frontmatter, links, conditional blocks, placeholders,
# scripts and render behavior. Safe to re-run; temporary validation copies are
# removed on exit.
#
# Usage: bash skills/agentic-kickoff/scripts/verify-skill.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
EXPECTED_SKILL_NAME='agentic-kickoff'

errors=0
fail() {
    printf '  FAIL: %s\n' "$1" >&2
    errors=$((errors + 1))
}

printf 'Verifying skill: %s\n' "${SKILL_DIR}"

SKILL_MD="${SKILL_DIR}/SKILL.md"
TEMPLATES_DIR="${SKILL_DIR}/assets/templates"
REFERENCES_DIR="${SKILL_DIR}/references"
ARTIFACTS_MD="${REFERENCES_DIR}/artifacts.md"

# --- 1. Required files ------------------------------------------------------
[ -f "${SKILL_MD}" ] || fail "missing SKILL.md"
[ -d "${TEMPLATES_DIR}" ] || fail "missing assets/templates/"
[ -d "${REFERENCES_DIR}" ] || fail "missing references/"
[ -f "${ARTIFACTS_MD}" ] || fail "missing references/artifacts.md"

if [ ! -f "${SKILL_MD}" ]; then
    printf 'Cannot continue without SKILL.md.\n' >&2
    exit 1
fi

# --- 2. Frontmatter ---------------------------------------------------------
frontmatter() {
    awk 'NR==1 && $0=="---" { in_fm=1; next } in_fm && $0=="---" { exit } in_fm { print }' "$1"
}

fm_value() {
    frontmatter "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -n 1 | sed -e 's/^"//' -e 's/"$//'
}

fm_has() {
    frontmatter "$1" | grep -qE "^$2:[[:space:]]*[^[:space:]]"
}

if [ "$(head -n 1 "${SKILL_MD}")" != "---" ]; then
    fail "SKILL.md does not start with YAML frontmatter"
else
    fm_has "${SKILL_MD}" name || fail "frontmatter is missing a non-empty 'name'"
    fm_has "${SKILL_MD}" description || fail "frontmatter is missing a non-empty 'description'"

    name="$(fm_value "${SKILL_MD}" name)"
    description="$(fm_value "${SKILL_MD}" description)"
    compatibility="$(fm_value "${SKILL_MD}" compatibility)"

    if [ -n "${name}" ]; then
        [ "${name}" = "${EXPECTED_SKILL_NAME}" ] || fail "frontmatter name '${name}' does not match '${EXPECTED_SKILL_NAME}'"
        if ! printf '%s' "${name}" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
            fail "name '${name}' must be lowercase alphanumerics with single hyphens"
        fi
        [ "${#name}" -le 64 ] || fail "name is longer than 64 characters"
    fi

    if [ -n "${description}" ]; then
        [ "${#description}" -le 1024 ] || fail "description is longer than 1024 characters"
    fi

    if [ -n "${compatibility}" ]; then
        [ "${#compatibility}" -le 500 ] || fail "compatibility is longer than 500 characters"
    fi
fi

# Use the official parser when npx is available. Copy to a correctly named
# directory because repository checkouts are not guaranteed to use the skill's
# directory name.
if command -v npx >/dev/null 2>&1; then
    validation_tmp="$(mktemp -d)"
    validation_skill="${validation_tmp}/${EXPECTED_SKILL_NAME}"
    mkdir -p "$validation_skill"
    cp -R "${SKILL_DIR}/." "$validation_skill/"
    if ! npx --yes skills-ref validate "$validation_skill" >/dev/null; then
        fail "official skills-ref validation failed"
    fi
    rm -rf "$validation_tmp"
else
    printf '  WARN: npx not found; official skills-ref validation skipped.\n' >&2
fi

# --- 3. Body length ---------------------------------------------------------
fm_lines="$(frontmatter "${SKILL_MD}" | wc -l | tr -d ' ')"
total_lines="$(wc -l < "${SKILL_MD}" | tr -d ' ')"
body_lines=$((total_lines - fm_lines - 2))
if [ "${body_lines}" -gt 500 ]; then
    fail "SKILL.md body is ${body_lines} lines (recommended maximum is 500)"
fi

# --- 4. Relative links in SKILL.md and references/ --------------------------
# Portable path normalization: no readlink -f (absent on macOS).
join_path() {
    local dir="$1" rel="$2" part
    local IFS='/'
    for part in ${rel}; do
        case "${part}" in
        '' | '.') ;;
        '..') dir="$(dirname "${dir}")" ;;
        *) dir="${dir}/${part}" ;;
        esac
    done
    printf '%s' "${dir}"
}

check_links() {
    local file="$1" match target target_path base
    base="$(dirname "${file}")"
    while IFS= read -r match; do
        [ -n "${match}" ] || continue
        target="${match#*](}"
        target="${target%)}"
        case "${target}" in
        '' | '#'* | http://* | https://* | mailto:* | /*) continue ;;
        esac
        target_path="${target%%#*}"
        [ -n "${target_path}" ] || continue
        if [ ! -e "$(join_path "${base}" "${target_path}")" ]; then
            fail "broken relative link in ${file#"${SKILL_DIR}/"}: ${target}"
        fi
    done < <(grep -oE '\]\([^)]+\)' "${file}" || true)
}

check_links "${SKILL_MD}"
while IFS= read -r ref; do
    [ -n "${ref}" ] || continue
    check_links "${ref}"
done < <(find "${REFERENCES_DIR}" -type f -name '*.md' | sort)

# --- 5. Templates -----------------------------------------------------------
expected_templates="MANIFESTO.md.tmpl MASTERPLAN.md.tmpl AGENTS.md.tmpl coding-standards.md.tmpl KICKOFF-BRIEF.md.tmpl TASK-TREE.md.tmpl specs-README.md.tmpl SPEC.md.tmpl"
for tmpl in ${expected_templates}; do
    [ -f "${TEMPLATES_DIR}/${tmpl}" ] || fail "missing template ${tmpl}"
done

# Conditional markers must be balanced and paired per template.
while IFS= read -r tmpl; do
    [ -n "${tmpl}" ] || continue
    begin_labels="$(grep -oE '<!-- BEGIN: [a-z0-9-]+ -->' "${tmpl}" | sed -e 's/<!-- BEGIN: //' -e 's/ -->//' | sort || true)"
    end_labels="$(grep -oE '<!-- END: [a-z0-9-]+ -->' "${tmpl}" | sed -e 's/<!-- END: //' -e 's/ -->//' | sort || true)"
    if [ "${begin_labels}" != "${end_labels}" ]; then
        fail "unbalanced conditional blocks in $(basename "${tmpl}")"
    fi
    while IFS= read -r marker_line; do
        [ -n "${marker_line}" ] || continue
        if ! printf '%s' "${marker_line}" | grep -qE '^[[:space:]]*<!-- (BEGIN|END): [a-z0-9-]+ -->[[:space:]]*$'; then
            fail "conditional marker must be alone on its line in $(basename "${tmpl}")"
        fi
    done < <(grep -E '<!-- (BEGIN|END): ' "${tmpl}" || true)
done < <(find "${TEMPLATES_DIR}" -type f -name '*.tmpl' | sort)

# Every template placeholder must be documented in references/artifacts.md.
placeholders="$(grep -rhoE '\{\{[A-Z0-9_]+\}\}' "${TEMPLATES_DIR}" | sort -u || true)"
if [ -z "${placeholders}" ]; then
    fail "no placeholders found in templates; the placeholder contract is not enforced"
else
    while IFS= read -r placeholder; do
        [ -n "${placeholder}" ] || continue
        grep -qF "${placeholder}" "${ARTIFACTS_MD}" || fail "placeholder ${placeholder} is not documented in references/artifacts.md"
    done <<< "${placeholders}"
fi

# Every documented placeholder must also occur in a template, so the contract
# cannot silently retain obsolete names.
documented_placeholders="$(grep -oE '\{\{[A-Z0-9_]+\}\}' "${ARTIFACTS_MD}" | grep -v '^{{PLACEHOLDER}}$' | sort -u || true)"
while IFS= read -r placeholder; do
    [ -n "${placeholder}" ] || continue
    grep -qFx "${placeholder}" <<< "${placeholders}" || \
        fail "documented placeholder ${placeholder} is not used by any template"
done <<< "${documented_placeholders}"

# Every conditional label in a template must be documented, and documented
# labels must be exercised by the rendering matrix.
template_labels="$(grep -rhoE '<!-- BEGIN: [a-z0-9-]+ -->' "${TEMPLATES_DIR}" | sed -e 's/<!-- BEGIN: //' -e 's/ -->//' | sort -u || true)"
while IFS= read -r label; do
    [ -n "${label}" ] || continue
    grep -qF "\`${label}\`" "${ARTIFACTS_MD}" || \
        fail "conditional label '${label}' is not documented in references/artifacts.md"
    grep -qF "$label" "${SCRIPT_DIR}/test-render.sh" || \
        fail "conditional label '${label}' is not covered by test-render.sh"
done <<< "${template_labels}"

# Templates must stay vendor-neutral and free of identifier-like secrets.
forbidden='AgentCore|Bedrock|Serverless Coding Harness|microVM|sch deploy|sch task|Amazon Web Services|(^|[^A-Za-z0-9_])AWS([^A-Za-z0-9_]|$)'
while IFS= read -r tmpl; do
    [ -n "${tmpl}" ] || continue
    if grep -qE "${forbidden}" "${tmpl}"; then
        fail "template $(basename "${tmpl}") contains project-specific product wording"
    fi
    if grep -qE '(^|[^0-9a-fA-F-])[0-9]{12}([^0-9a-fA-F-]|$)' "${tmpl}"; then
        fail "template $(basename "${tmpl}") contains a 12-digit identifier"
    fi
    if grep -qE '/home/[A-Za-z0-9._-]+' "${tmpl}"; then
        fail "template $(basename "${tmpl}") contains an absolute home path"
    fi
done < <(find "${TEMPLATES_DIR}" -type f -name '*.tmpl' | sort)

# --- 6. Scripts parse -------------------------------------------------------
while IFS= read -r script; do
    [ -n "${script}" ] || continue
    bash -n "${script}" || fail "bash syntax error in $(basename "${script}")"
done < <(find "${SCRIPT_DIR}" -type f -name '*.sh' | sort)

# --- 7. Render smoke test ---------------------------------------------------
if [ -f "${SCRIPT_DIR}/test-render.sh" ]; then
    bash "${SCRIPT_DIR}/test-render.sh" || fail "template render test failed"
fi

# --- 8. Backlog detection behavior -----------------------------------------
if [ -f "${SCRIPT_DIR}/test-ensure-backlog.sh" ]; then
    bash "${SCRIPT_DIR}/test-ensure-backlog.sh" || fail "Backlog detection test failed"
fi

# --- 9. Backlog CLI integration smoke test ---------------------------------
if [ -f "${SCRIPT_DIR}/test-backlog-integration.sh" ]; then
    bash "${SCRIPT_DIR}/test-backlog-integration.sh" || fail "Backlog integration test failed"
fi

# --- Result -----------------------------------------------------------------
if [ "${errors}" -gt 0 ]; then
    printf 'FAILED: %s error(s).\n' "${errors}" >&2
    exit 1
fi
printf 'OK: %s (body %s lines, %s placeholders)\n' "${EXPECTED_SKILL_NAME}" "${body_lines}" "$(printf '%s' "${placeholders}" | grep -c . || true)"
