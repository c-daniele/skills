#!/usr/bin/env bash
# Minimal skill validation: every skills/*/SKILL.md must exist
# and declare matching name + non-empty description frontmatter.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

for dir in "$ROOT"/skills/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  file="$dir/SKILL.md"

  if [ ! -f "$file" ]; then
    echo "FAIL: $name: missing SKILL.md"
    fail=1
    continue
  fi

  # Extract frontmatter block (between first two --- lines)
  frontmatter="$(awk 'NR==1 && $0=="---"{f=1;next} f==1 && $0=="---"{exit} f==1{print}' "$file")"

  if ! printf '%s\n' "$frontmatter" | grep -qE "^name:[[:space:]]*$name[[:space:]]*$"; then
    echo "FAIL: $name: frontmatter 'name' must be exactly '$name'"
    fail=1
  fi

  if ! printf '%s\n' "$frontmatter" | grep -qE '^description:[[:space:]]*\S'; then
    echo "FAIL: $name: frontmatter 'description' is missing or empty"
    fail=1
  fi
done

if [ "$fail" -eq 1 ]; then
  echo "verify-skills: FAILED"
  exit 1
fi

echo "verify-skills: OK"
