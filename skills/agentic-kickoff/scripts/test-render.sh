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
    local root="${TMP}/${name}" rendered delegation_policy
    mkdir -p "${root}/.backlog/masterplan" "${root}/.backlog/tasks" \
        "${root}/.backlog/brainstorming"

    if label_enabled decisions "$enabled"; then mkdir -p "${root}/.backlog/decisions"; fi
    if label_enabled journal "$enabled"; then mkdir -p "${root}/.backlog/docs/journal"; fi
    if label_enabled standards "$enabled"; then mkdir -p "${root}/docs"; fi
    if label_enabled delegation "$enabled"; then mkdir -p "${root}/docs"; fi
    if label_enabled specs "$enabled"; then mkdir -p "${root}/docs/specs"; fi
    if label_enabled openspec "$enabled"; then
        mkdir -p "${root}/docs" "${root}/openspec/specs" "${root}/openspec/changes"
    fi

    render_one "${TEMPLATES_DIR}/MANIFESTO.md.tmpl" "$enabled" "${root}/MANIFESTO.md"
    render_one "${TEMPLATES_DIR}/MASTERPLAN.md.tmpl" "$enabled" "${root}/.backlog/masterplan/MASTERPLAN.md"
    render_one "${TEMPLATES_DIR}/AGENTS.md.tmpl" "$enabled" "${root}/AGENTS.md"
    render_one "${TEMPLATES_DIR}/KICKOFF-BRIEF.md.tmpl" "$enabled" "${root}/.backlog/brainstorming/KICKOFF-BRIEF.md"
    render_one "${TEMPLATES_DIR}/TASK-TREE.md.tmpl" "$enabled" "${root}/.backlog/brainstorming/TASK-TREE.md"

    delegation_policy='Use one primary agent. No standing delegation authorization.'
    if label_enabled delegation "$enabled" && [ "$name" != roles-single-agent ]; then
        delegation_policy='Allow one read-only reviewer on explicit request; advisory review with disclosed self-review fallback.'
    fi
    replace_literal "${root}/AGENTS.md" 'value-DELEGATION_POLICY' "$delegation_policy"
    replace_literal "${root}/.backlog/brainstorming/KICKOFF-BRIEF.md" 'value-DELEGATION_POLICY' "$delegation_policy"

    if label_enabled delegation "$enabled"; then
        render_one "${TEMPLATES_DIR}/agent-roles.md.tmpl" "$enabled" "${root}/docs/agent-roles.md"
        replace_literal "${root}/docs/agent-roles.md" 'value-AGENT_GUIDE_LINK' '[the agent guide](../AGENTS.md)'
        render_one "${TEMPLATES_DIR}/DELEGATION-HANDOFF.md.tmpl" "$enabled" \
            "${root}/.backlog/brainstorming/handoff.md"
        render_one "${TEMPLATES_DIR}/REVIEW-RESULT.md.tmpl" "$enabled" \
            "${root}/.backlog/brainstorming/review-result.md"
    fi

    if label_enabled standards "$enabled"; then
        render_one "${TEMPLATES_DIR}/coding-standards.md.tmpl" "$enabled" "${root}/docs/coding-standards.md"
    fi

    if label_enabled openspec "$enabled"; then
        render_one "${TEMPLATES_DIR}/spec-workflow.md.tmpl" "$enabled" "${root}/docs/spec-workflow.md"
        replace_literal "${root}/docs/spec-workflow.md" 'value-BACKLOG_DIR' '.backlog'
        replace_literal "${root}/docs/spec-workflow.md" 'value-SPEC_SOURCE_MAP' \
            '- Constitution: [Manifesto](../MANIFESTO.md).
- Outcomes: [Masterplan](../.backlog/masterplan/MASTERPLAN.md).'
        render_one "${TEMPLATES_DIR}/openspec-config.yaml.tmpl" "$enabled" "${root}/openspec/config.yaml"
        cp -R "${SKILL_DIR}/assets/openspec" "${root}/openspec/schemas"
        if [ "$name" = openspec-baseline ]; then
            mkdir -p "${root}/openspec/specs/core"
            render_one "${TEMPLATES_DIR}/OPENSPEC-BASELINE.md.tmpl" "$enabled" "${root}/openspec/specs/core/spec.md"
        fi
        render_one "${TEMPLATES_DIR}/BACKLOG-SPEC-TASK.md.tmpl" "$enabled" \
            "${root}/.backlog/brainstorming/task-description.md"
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

    if label_enabled openspec "$enabled"; then
        grep -q 'docs/spec-workflow.md' "${root}/AGENTS.md" || fail "${name}: Agent Guide lost hybrid workflow link"
        grep -q 'docs/spec-workflow.md' "${root}/.backlog/masterplan/MASTERPLAN.md" || fail "${name}: masterplan lost hybrid workflow link"
        [ ! -e "${root}/docs/specs" ] || fail "${name}: hybrid profile created a duplicate plain-spec tree"
    elif grep -q 'spec-workflow.md' "${root}/AGENTS.md" "${root}/.backlog/masterplan/MASTERPLAN.md"; then
        fail "${name}: hybrid workflow reference survived without its profile"
    fi

    grep -qF "$delegation_policy" "${root}/AGENTS.md" || fail "${name}: guide lost the approved delegation policy"
    if label_enabled delegation "$enabled"; then
        grep -q 'docs/agent-roles.md' "${root}/AGENTS.md" || fail "${name}: guide lost the role-contract link"
        if label_enabled openspec "$enabled"; then
            grep -q 'agent-roles.md' "${root}/docs/spec-workflow.md" || fail "${name}: hybrid workflow lost the role-contract link"
        elif grep -q 'spec-workflow.md' "${root}/docs/agent-roles.md"; then
            fail "${name}: roles require an unselected OpenSpec profile"
        fi
    else
        [ ! -e "${root}/docs/agent-roles.md" ] || fail "${name}: role contracts were created without selection"
        if grep -q 'agent-roles.md' "${root}/AGENTS.md"; then
            fail "${name}: role-contract link survived without its document"
        fi
        if label_enabled openspec "$enabled" && grep -q 'agent-roles.md' "${root}/docs/spec-workflow.md"; then
            fail "${name}: hybrid workflow requires unselected role contracts"
        fi
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
render_scenario openspec-only 'openspec'
render_scenario openspec-baseline 'openspec'
render_scenario openspec-standards 'openspec standards node tests decisions'
render_scenario delegation-only 'delegation'
render_scenario specs-and-delegation 'specs delegation'
render_scenario openspec-and-delegation 'openspec delegation'
render_scenario roles-single-agent 'delegation'

# Adoption uses an actual custom board and existing product context, with no
# dependency on greenfield core documents.
adoption_root="${TMP}/brownfield"
mkdir -p "${adoption_root}/docs" "${adoption_root}/work-items/brainstorming"
printf '# Existing product context\n' > "${adoption_root}/docs/product.md"
render_one "${TEMPLATES_DIR}/spec-workflow.md.tmpl" openspec "${adoption_root}/docs/spec-workflow.md"
replace_literal "${adoption_root}/docs/spec-workflow.md" 'value-BACKLOG_DIR' 'work-items'
replace_literal "${adoption_root}/docs/spec-workflow.md" 'value-SPEC_SOURCE_MAP' \
    '- Product intent: [Existing product context](product.md).'
render_one "${TEMPLATES_DIR}/AGENTS-spec-workflow.md.tmpl" openspec "${adoption_root}/AGENTS.md"
replace_literal "${adoption_root}/AGENTS.md" 'value-BACKLOG_DIR' 'work-items'
render_one "${TEMPLATES_DIR}/ADOPTION-BRIEF.md.tmpl" openspec \
    "${adoption_root}/work-items/brainstorming/ADOPTION-BRIEF.md"
while IFS= read -r rendered; do
    check_file "$rendered" brownfield
done < <(find "$adoption_root" -type f -name '*.md' | sort)
if grep -qE '\.backlog/|MANIFESTO.md|MASTERPLAN.md' "${adoption_root}/AGENTS.md" "${adoption_root}/docs/spec-workflow.md"; then
    fail 'brownfield: adoption imposed greenfield paths on an existing project'
fi

# An approved role-policy addition can target a nested guide without introducing
# a root guide, OpenSpec tree or a new task board.
nested_root="${TMP}/nested-guide"
mkdir -p "${nested_root}/src" "${nested_root}/docs"
printf '# Existing scoped guide\nKeep this approved project instruction.\n' > "${nested_root}/src/AGENTS.md"
render_one "${TEMPLATES_DIR}/AGENTS-delegation.md.tmpl" delegation "${TMP}/guide-addition.md"
replace_literal "${TMP}/guide-addition.md" 'value-DELEGATION_POLICY' 'Allow a read-only reviewer on request.'
replace_literal "${TMP}/guide-addition.md" '](docs/agent-roles.md)' '](../docs/agent-roles.md)'
cat "${TMP}/guide-addition.md" >> "${nested_root}/src/AGENTS.md"
render_one "${TEMPLATES_DIR}/agent-roles.md.tmpl" delegation "${nested_root}/docs/agent-roles.md"
replace_literal "${nested_root}/docs/agent-roles.md" 'value-AGENT_GUIDE_LINK' '[the scoped guide](../src/AGENTS.md)'
check_file "${nested_root}/src/AGENTS.md" nested-guide
check_file "${nested_root}/docs/agent-roles.md" nested-guide
grep -q 'Keep this approved project instruction.' "${nested_root}/src/AGENTS.md" || fail 'nested-guide: existing guide content was lost'
[ ! -e "${nested_root}/AGENTS.md" ] || fail 'nested-guide: root guide was invented'

# A single-agent policy can also be adopted without installing the role document.
render_one "${TEMPLATES_DIR}/AGENTS-delegation.md.tmpl" '' "${TMP}/single-agent-addition.md"
replace_literal "${TMP}/single-agent-addition.md" 'value-DELEGATION_POLICY' 'Use one primary agent only.'
check_file "${TMP}/single-agent-addition.md" single-agent-addition
if grep -q 'agent-roles.md' "${TMP}/single-agent-addition.md"; then
    fail 'single-agent-addition: unselected role-document link survived'
fi

if [ "$errors" -gt 0 ]; then
    printf 'FAILED: %s render test error(s).\n' "$errors" >&2
    exit 1
fi
printf 'OK: templates render clean across fourteen profile scenarios and custom-board/nested-guide adoption.\n'
