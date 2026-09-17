#!/usr/bin/env bash
# Smoke-test the documented Backlog.md initialization and task workflow.
set -euo pipefail

if ! command -v backlog >/dev/null 2>&1; then
    printf 'SKIP: backlog is not installed; integration smoke test not run.\n'
    exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
project="${TMP}/project"
mkdir -p "$project"

(
    cd "$project"
    BACKLOG_CWD="$PWD" backlog init 'Integration Fixture' --defaults --integration-mode none \
        --backlog-dir .backlog --config-location folder --no-git >/dev/null
    mkdir -p .backlog/masterplan .backlog/brainstorming

    [ -f .backlog/config.yml ]
    [ -d .backlog/masterplan ]
    [ -d .backlog/brainstorming ]
    [ ! -e AGENTS.md ]

    parent_output="$(BACKLOG_CWD="$PWD" backlog task create 'Verified parent' --type feature \
        -d 'Approved parent outcome.' --ac 'Parent outcome is reviewable.' \
        --priority High --status 'To Do' --plain)"
    parent_id="$(printf '%s\n' "$parent_output" | sed -n 's/^Task \([^ ]*\) -.*/\1/p' | head -n 1)"
    [ -n "$parent_id" ]

    child_output="$(BACKLOG_CWD="$PWD" backlog task create -p "$parent_id" 'Verified child' \
        --type task -d 'Approved child outcome.' \
        --ac 'Child outcome has objective evidence.' --priority Medium \
        --status 'To Do' --plain)"
    child_id="$(printf '%s\n' "$child_output" | sed -n 's/^Task \([^ ]*\) -.*/\1/p' | head -n 1)"
    [ -n "$child_id" ]

    task_json="$(BACKLOG_CWD="$PWD" backlog task list --json)"
    grep -q "$parent_id" <<< "$task_json"
    grep -q "$child_id" <<< "$task_json"
    parent_json="$(BACKLOG_CWD="$PWD" backlog task view "$parent_id" --json)"
    child_json="$(BACKLOG_CWD="$PWD" backlog task view "$child_id" --json)"
    grep -q 'Parent outcome is reviewable.' <<< "$parent_json"
    grep -q '"priority": "high"' <<< "$parent_json"
    grep -q '"status": "To Do"' <<< "$parent_json"
    grep -q "\"parentTaskId\": \"${parent_id}\"" <<< "$child_json"
    grep -q '"priority": "medium"' <<< "$child_json"
)

printf 'OK: current Backlog.md supports documented init, parent and child workflow.\n'
