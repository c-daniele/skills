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
    printf '%s' "$1" | sed -E \
        -e 's/\{\{PROJECT_NAME\}\}/Loan Desk/g' \
        -e 's/\{\{PROJECT_SLUG\}\}/loan-desk/g' \
        -e 's/\{\{ONE_LINER\}\}/Loan Desk helps librarians lend equipment and record its return./g' \
        -e 's/\{\{PROBLEM\}\}/Reconciling paper slips delays answers at the lending desk./g' \
        -e 's/\{\{USERS_AND_JOBS\}\}/Desk librarians issue equipment and record returns./g' \
        -e 's/\{\{PRIORITY_RULE\}\}/the desk librarian’s ability to find a borrower comes first./g' \
        -e 's/\{\{CORE_LOOP\}\}/A librarian records the loan, finds it when the item comes back, and records the return./g' \
        -e 's/\{\{DESIGN_PRINCIPLES\}\}/Keep borrower names visible only at the staffed desk./g' \
        -e 's/\{\{BOUNDARIES\}\}/Limit the trial to one desk. Do not collect fines./g' \
        -e 's/\{\{RISKS\}\}/If a librarian cannot identify the borrower, pause the trial and review the record./g' \
        -e 's/\{\{WORKING_AGREEMENT\}\}/Create a task for work affecting a loan or return. Reserve To Do for approved items; keep proposals in drafts./g' \
        -e 's/\{\{REVIEW_POLICY\}\}/Ask the head librarian to review changes to borrower access before implementation./g' \
        -e 's/\{\{PLAN_PURPOSE\}\}/Librarians need to see who has borrowed each item without reconciling paper slips./g' \
        -e 's/\{\{GOALS\}\}/A librarian can identify who has an item during a desk enquiry./g' \
        -e 's/\{\{SUCCESS_CRITERIA\}\}/In a desk trial, a librarian can record a return and find the item without help./g' \
        -e 's/\{\{PLAN_SCOPE\}\}/The first release covers loans and returns at one desk. Fines are out of scope./g' \
        -e 's/\{\{CONSTRAINTS\}\}/Only desk staff may see borrower names./g' \
        -e 's/\{\{PLANNING_ASSUMPTIONS\}\}/The first trial assumes one staffed desk. Revisit the design before adding a second./g' \
        -e 's/\{\{ROADMAP\}\}/First prove the return workflow at one desk, then assess a second location./g' \
        -e 's/\{\{GLOSSARY\}\}/A loan is the period from handing over an item to recording its return./g' \
        -e 's/\{\{DIRECTION_QUESTIONS\}\}/The head librarian must decide whether the trial needs more than one location./g' \
        -e 's/\{\{([A-Z0-9_]+)\}\}/value-\1/g'
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
    local root="${3:-${TMP}/${name}}" rendered delegation_policy settings
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

    local truth='[Manifesto](MANIFESTO.md) and [masterplan](.backlog/masterplan/MASTERPLAN.md)'
    if label_enabled specs "$enabled"; then truth="[Approved domain specs](docs/specs/README.md) for covered behavior; otherwise $truth"; fi
    if label_enabled openspec "$enabled"; then truth='[Specification source map](docs/spec-workflow.md)'; fi
    replace_literal "${root}/MANIFESTO.md" 'value-ARCHITECTURE_TRUTH' "$truth"

    mkdir -p "${root}/scripts"
    if [ ! -f "${root}/.backlog/config.yml" ]; then
        printf 'project_name: Loan Desk\nstatuses: [To Do, In Progress, Done]\n' > "${root}/.backlog/config.yml"
    fi
    settings='{"project":"Loan Desk","intro":"Loan Desk helps librarians lend equipment and record its return.","config":".backlog/config.yml","view":"WORKPLAN.md","masterplan":".backlog/masterplan/MASTERPLAN.md","statuses":{"To Do":"ready","In Progress":"active","Done":"done"}}'
    render_one "${TEMPLATES_DIR}/workplan.rb.tmpl" "$enabled" "${root}/scripts/workplan.rb"
    replace_literal "${root}/scripts/workplan.rb" value-WORKPLAN_SETTINGS "$settings"
    replace_literal "${root}/.backlog/brainstorming/KICKOFF-BRIEF.md" value-WORKPLAN_SETTINGS "$settings"
    (cd "$root" && ruby scripts/workplan.rb --stdout > WORKPLAN.md && ruby scripts/workplan.rb --check)
    grep -q 'No executable work has been defined yet' "${root}/WORKPLAN.md" || fail "${name}: empty board misrepresented"
    grep -qF '](WORKPLAN.md)' "${root}/AGENTS.md" || fail "${name}: guide lost workplan link"
    grep -qF '](.backlog/masterplan/MASTERPLAN.md)' "${root}/AGENTS.md" || fail "${name}: guide lost masterplan link"
    grep -qF '](../../WORKPLAN.md)' "${root}/.backlog/masterplan/MASTERPLAN.md" || fail "${name}: masterplan lost workplan link"
    grep -qF '](.backlog/masterplan/MASTERPLAN.md)' "${root}/WORKPLAN.md" || fail "${name}: workplan lost masterplan link"

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
- Outcomes: [Masterplan](../.backlog/masterplan/MASTERPLAN.md).
- Daily progress: [Workplan](../WORKPLAN.md).'
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

# Reuse the same document proposals for the real-board recovery test.
if [ "${1:-}" = --fixture ]; then
    render_scenario minimal '' "$2"
    exit "$errors"
fi

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
