#!/usr/bin/env bash
# Behavioral tests for ensure-backlog.sh. All command doubles live in a temp dir.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENSURE="${SCRIPT_DIR}/ensure-backlog.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT
TEST_PATH="${TMP}/bin"
mkdir -p "$TEST_PATH"
ln -s "$(command -v head)" "${TEST_PATH}/head"
ln -s "$(command -v sed)" "${TEST_PATH}/sed"

errors=0
fail() {
    printf '  FAIL: %s\n' "$1" >&2
    errors=$((errors + 1))
}

make_backlog() {
    local version="$1"
    cat > "${TMP}/bin/backlog" <<EOF
#!/bin/bash
printf '%s\\n' '${version}'
EOF
    chmod +x "${TMP}/bin/backlog"
}

run_expect() {
    local expected="$1" label="$2"
    shift 2
    local status=0
    "$@" >"${TMP}/${label}.out" 2>"${TMP}/${label}.err" || status=$?
    if [ "$status" -ne "$expected" ]; then
        fail "${label}: expected exit ${expected}, got ${status}"
    fi
}

make_backlog '1.50.1'
run_expect 0 supported env PATH="$TEST_PATH" /bin/bash "$ENSURE"

make_backlog '1.50.0'
run_expect 7 too-old env PATH="$TEST_PATH" /bin/bash "$ENSURE"

make_backlog '2.0.0'
run_expect 7 future-major env PATH="$TEST_PATH" /bin/bash "$ENSURE"

make_backlog 'not-a-version'
run_expect 7 malformed env PATH="$TEST_PATH" /bin/bash "$ENSURE"

make_backlog '1.50.1-beta.1'
run_expect 7 prerelease env PATH="$TEST_PATH" /bin/bash "$ENSURE"

make_backlog '1.50.1.2'
run_expect 7 extra-component env PATH="$TEST_PATH" /bin/bash "$ENSURE"

rm -f "${TMP}/bin/backlog"
cat > "${TMP}/bin/npm" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "${TMP}/bin/npm"
run_expect 3 unauthorized env PATH="$TEST_PATH" /bin/bash "$ENSURE"
run_expect 6 install-failed env PATH="$TEST_PATH" AGENTIC_KICKOFF_INSTALL=1 /bin/bash "$ENSURE"

cat > "${TMP}/bin/npm" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "${TMP}/bin/npm"
run_expect 5 install-not-on-path env PATH="$TEST_PATH" AGENTIC_KICKOFF_INSTALL=1 /bin/bash "$ENSURE"

if [ "$errors" -gt 0 ]; then
    printf 'FAILED: %s ensure-backlog test error(s).\n' "$errors" >&2
    exit 1
fi
printf 'OK: ensure-backlog accepts only the supported CLI range and reports install failures.\n'
