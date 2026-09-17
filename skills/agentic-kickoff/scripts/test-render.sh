#!/usr/bin/env bash
# Render supported conditional combinations and verify clean, linked Markdown.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATES_DIR="${SKILL_DIR}/assets/templates"

errors=0
fail() {
    printf '  FAIL: %s\n' "$1" >&2
    errors=$((errors + 1))
}

placeholders="$(grep -rhoE '\{\{[A-Z0-9_]+\}\}' "${TEMPLATES_DIR}" | sort -u || true)"
if [ -z "$placeholders" ]; then
    printf 'FAILED: no placeholders found; render test would be vacuous.\n' >&2
    exit 1
fi

replace_placeholders() {
    local content="$1" placeholder name
    while IFS= read -r placeholder; do
        [ -n "$placeholder" ] || continue
        name="${placeholder#\{\{}"
        name="${name%\}\}}"
        content="$(printf '%s' "$content" | sed "s/${placeholder}/value-${name}/g")"
    done <<< "$placeholders"
    printf '%s' "$content"
}

replace_literal() {
    local file="$1" token="$2" value="$3" content
    content="$(<"$file")"
    content="${content//${token}/${value}}"
    printf '%s' "$content" > "$file"
}

label_enabled() {
    local label="$1" enabled="$2"
    case " ${enabled} " in
    *" ${label} "*) return 0 ;;
    *) return 1 ;;
    esac
}

render_one() {
    local tmpl="$1" enabled="$2" dest="$3"
    local line label skip=0 guidance=0 content=''
    while IFS= read -r line || [ -n "$line" ]; do
        if [ "$guidance" -eq 1 ]; then
            case "$line" in *'-->'*) guidance=0 ;; esac
            continue
        fi
        case "$line" in
        '<!-- BEGIN: '*' -->')
            label="${line#<!-- BEGIN: }"
            label="${label% -->}"
            if label_enabled "$label" "$enabled"; then skip=0; else skip=1; fi
            continue
            ;;
        '<!-- END: '*' -->')
            skip=0
            continue
            ;;
        '<!-- guidance:'*)
            case "$line" in *'-->'*) ;; *) guidance=1 ;; esac
            continue
            ;;
        esac
        [ "$skip" -eq 0 ] || continue
        content="${content}${line}"$'\n'
    done < "$tmpl"
    replace_placeholders "$content" > "$dest"
}

join_path() {
    local dir="$1" rel="$2" part
    local IFS='/'
    for part in $rel; do
        case "$part" in
        '' | '.') ;;
        '..') dir="$(dirname "$dir")" ;;
        *) dir="${dir}/${part}" ;;
        esac
    done
    printf '%s' "$dir"
}

check_file() {
    local file="$1" scenario="$2" match target target_path base
    base="$(dirname "$file")"
    if grep -q '{{' "$file"; then fail "${scenario}: ${file##*/} has an unrendered placeholder"; fi
    if grep -qE '<!-- (BEGIN|END): ' "$file"; then fail "${scenario}: ${file##*/} has a conditional marker"; fi
    if grep -qi 'guidance:' "$file"; then fail "${scenario}: ${file##*/} has a guidance comment"; fi

    while IFS= read -r match; do
        [ -n "$match" ] || continue
        target="${match#*](}"
        target="${target%)}"
        case "$target" in
        '' | '#'* | http://* | https://* | mailto:* | /*) continue ;;
        esac
        target_path="${target%%#*}"
        [ -n "$target_path" ] || continue
        if [ ! -e "$(join_path "$base" "$target_path")" ]; then
            fail "${scenario}: ${file##*/} has a dangling link: ${target}"
        fi
    done < <(grep -oE '\]\([^)]+\)' "$file" || true)
}

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

render_scenario() {
    local name="$1" enabled="$2"
    local root="${TMP}/${name}" rendered
    mkdir -p "${root}/.backlog/masterplan" "${root}/.backlog/tasks" \
        "${root}/.backlog/brainstorming"

    if label_enabled decisions "$enabled"; then mkdir -p "${root}/.backlog/decisions"; fi
    if label_enabled journal "$enabled"; then mkdir -p "${root}/.backlog/docs/journal"; fi
    if label_enabled standards "$enabled"; then mkdir -p "${root}/docs"; fi
    if label_enabled specs "$enabled"; then mkdir -p "${root}/docs/specs"; fi

    render_one "${TEMPLATES_DIR}/MANIFESTO.md.tmpl" "$enabled" "${root}/MANIFESTO.md"
    render_one "${TEMPLATES_DIR}/MASTERPLAN.md.tmpl" "$enabled" "${root}/.backlog/masterplan/MASTERPLAN.md"
    render_one "${TEMPLATES_DIR}/AGENTS.md.tmpl" "$enabled" "${root}/AGENTS.md"
    render_one "${TEMPLATES_DIR}/KICKOFF-BRIEF.md.tmpl" "$enabled" "${root}/.backlog/brainstorming/KICKOFF-BRIEF.md"

    if label_enabled standards "$enabled"; then
        render_one "${TEMPLATES_DIR}/coding-standards.md.tmpl" "$enabled" "${root}/docs/coding-standards.md"
    fi
    if label_enabled tests "$enabled"; then
        replace_literal "${root}/AGENTS.md" 'value-TEST_COMMANDS' \
            'npm test
    npm run lint'
    fi
    if label_enabled specs "$enabled"; then
        render_one "${TEMPLATES_DIR}/specs-README.md.tmpl" "$enabled" "${root}/docs/specs/README.md"
        if [ "$name" = full ]; then
            render_one "${TEMPLATES_DIR}/SPEC.md.tmpl" "$enabled" "${root}/docs/specs/core.md"
            replace_literal "${root}/docs/specs/README.md" 'value-SPEC_DOMAINS' '[Core](core.md)'
        else
            replace_literal "${root}/docs/specs/README.md" 'value-SPEC_DOMAINS' 'No domain specifications have been approved yet.'
        fi
    fi

    while IFS= read -r rendered; do
        [ -n "$rendered" ] || continue
        check_file "$rendered" "$name"
    done < <(find "$root" -type f -name '*.md' | sort)

    if label_enabled specs "$enabled"; then
        grep -q 'docs/specs/README.md' "${root}/AGENTS.md" || fail "${name}: Agent Guide lost specs link"
        if [ "$name" = full ]; then
            grep -q '\[Core\](core.md)' "${root}/docs/specs/README.md" || fail "${name}: specs index lost domain link"
            [ -f "${root}/docs/specs/core.md" ] || fail "${name}: linked domain spec was not rendered"
        else
            grep -q 'No domain specifications have been approved yet.' "${root}/docs/specs/README.md" || fail "${name}: empty specs index is unclear"
        fi
    elif grep -q 'docs/specs' "${root}/AGENTS.md" "${root}/.backlog/masterplan/MASTERPLAN.md"; then
        fail "${name}: specs reference survived without specs"
    fi

    if label_enabled standards "$enabled"; then
        grep -q 'docs/coding-standards.md' "${root}/AGENTS.md" || fail "${name}: Agent Guide lost standards link"
    elif grep -q 'coding-standards' "${root}/AGENTS.md"; then
        fail "${name}: standards reference survived without standards"
    fi

    if ! label_enabled tests "$enabled" && grep -q 'Approved project checks' "${root}/AGENTS.md"; then
        fail "${name}: test block survived without approved commands"
    elif label_enabled tests "$enabled"; then
        grep -q '^    npm test$' "${root}/AGENTS.md" || fail "${name}: first test command lost list indentation"
        grep -q '^    npm run lint$' "${root}/AGENTS.md" || fail "${name}: later test command lost list indentation"
    fi
    if ! label_enabled setup "$enabled" && grep -q '^## Environment setup' "${root}/AGENTS.md"; then
        fail "${name}: setup block survived without approved commands"
    fi

    # Conditional rows are list items, so enabling or removing them cannot split
    # the two fixed Markdown tables.
    [ "$(grep -c '^| --- | --- |$' "${root}/MANIFESTO.md")" -eq 1 ] || fail "${name}: Manifesto table structure changed"
}

render_scenario minimal ''
render_scenario specs-only 'specs'
render_scenario standards-only 'standards python'
render_scenario specs-and-standards 'specs standards node'
render_scenario full 'specs standards surfaces journal decisions git setup tests python node bash other'
render_scenario mixed-stack 'standards python bash tests'
render_scenario decisions-only 'decisions'

if [ "$errors" -gt 0 ]; then
    printf 'FAILED: %s render test error(s).\n' "$errors" >&2
    exit 1
fi
printf 'OK: templates render clean across seven conditional scenarios.\n'
