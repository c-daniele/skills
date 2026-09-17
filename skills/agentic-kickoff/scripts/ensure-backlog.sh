#!/usr/bin/env bash
# ensure-backlog.sh - detect the Backlog.md CLI required by agentic-kickoff.
#
# Usage:
#   bash scripts/ensure-backlog.sh
#   AGENTIC_KICKOFF_INSTALL=1 bash scripts/ensure-backlog.sh   # install if missing
#
# Exit codes:
#   0  backlog is available (its version is printed)
#   3  backlog is missing and automatic install was not authorized
#   4  npm is missing, so the CLI cannot be installed here
#   5  the install ran but `backlog` is still not on PATH
#   6  the install command failed
#   7  the installed backlog version is malformed or unsupported
set -euo pipefail

# The complete CLI workflow used by the skill is supported in this range.
MIN_MAJOR=1
MIN_MINOR=50
MIN_PATCH=1
MAX_MAJOR=2
BACKLOG_PACKAGE='backlog.md@^1.50.1'

check_version() {
    local output version major minor patch
    output="$(backlog --version 2>/dev/null | head -n 1 || true)"
    version="$(printf '%s' "$output" | sed -n 's/^[^0-9]*\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)[[:space:]]*$/\1/p')"
    if [ -z "$version" ]; then
        printf 'agentic-kickoff: cannot parse the Backlog.md version from %s. Require >=%s.%s.%s and <%s.0.0.\n' \
            "${output:-<empty output>}" "$MIN_MAJOR" "$MIN_MINOR" "$MIN_PATCH" "$MAX_MAJOR" >&2
        return 7
    fi

    major="${version%%.*}"
    minor="${version#*.}"
    minor="${minor%%.*}"
    patch="${version##*.}"
    if [ "$major" -ge "$MAX_MAJOR" ] || [ "$major" -lt "$MIN_MAJOR" ] ||
        { [ "$major" -eq "$MIN_MAJOR" ] && [ "$minor" -lt "$MIN_MINOR" ]; } ||
        { [ "$major" -eq "$MIN_MAJOR" ] && [ "$minor" -eq "$MIN_MINOR" ] && [ "$patch" -lt "$MIN_PATCH" ]; }; then
        printf 'agentic-kickoff: Backlog.md %s is unsupported. Require >=%s.%s.%s and <%s.0.0.\n' \
            "$version" "$MIN_MAJOR" "$MIN_MINOR" "$MIN_PATCH" "$MAX_MAJOR" >&2
        return 7
    fi

    printf 'backlog %s\n' "$version"
}

install_backlog() {
    if [ "${AGENTIC_KICKOFF_INSTALL:-0}" != "1" ]; then
        return 3
    fi
    if ! command -v npm >/dev/null 2>&1; then
        printf 'agentic-kickoff: npm not found. Install a currently supported Node.js LTS release, then retry.\n' >&2
        return 4
    fi
    if ! npm install -g "$BACKLOG_PACKAGE"; then
        printf 'agentic-kickoff: "npm install -g %s" failed.\n' "$BACKLOG_PACKAGE" >&2
        return 6
    fi
    if ! command -v backlog >/dev/null 2>&1; then
        printf 'agentic-kickoff: the install finished but "backlog" is still not on PATH.\n' >&2
        return 5
    fi
    return 0
}

if command -v backlog >/dev/null 2>&1; then
    check_version
    exit $?
fi

status=0
install_backlog || status=$?
case "$status" in
0)
    check_version
    exit $?
    ;;
3)
    printf 'agentic-kickoff: the Backlog.md CLI ("backlog") is not installed.\n' >&2
    printf 'Install it with: npm install -g "%s"\n' "$BACKLOG_PACKAGE" >&2
    printf 'Or let the skill install it: AGENTIC_KICKOFF_INSTALL=1 %s\n' "$0" >&2
    exit 3
    ;;
*)
    exit "$status"
    ;;
esac
