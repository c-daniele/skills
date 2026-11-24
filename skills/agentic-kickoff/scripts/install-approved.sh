#!/usr/bin/env bash
# Install one verified greenfield postimage. Run from the approved project root.
set -euo pipefail
[[ $# == 3 ]] || { echo 'Usage: install-approved.sh STAGED RELATIVE_DEST SHA256' >&2; exit 2; }
src=$1 dest=$2 expected=$3
case "/$dest/" in *'//'*|*'/../'*|*'/./'*) echo "Invalid destination: $dest" >&2; exit 1 ;; esac
check() { [[ -f $1 && ! -L $1 && $(shasum -a 256 < "$1" | cut -d' ' -f1) == "$expected" ]]; }
check "$src" || { echo "Staged checksum mismatch: $src" >&2; exit 1; }
parent=$(dirname "$dest")
# Check each existing ancestor before creating any missing directories.
dir=$parent
while [[ $dir != . ]]; do
    [[ ! -L $dir ]] || { echo "Linked destination directory: $dir" >&2; exit 1; }
    dir=$(dirname "$dir")
done
if [[ -e $dest || -L $dest ]]; then
    check "$dest" || { echo "Conflicting destination: $dest" >&2; exit 1; }
    exit 0
fi
mkdir -p "$parent"
tmp=$(mktemp "$parent/.kickoff.XXXXXX")
trap 'rm -f "$tmp"' EXIT
cp -p "$src" "$tmp"
check "$tmp"
# link(2) fails if the final path appeared, including if it is a directory.
ruby -e 'File.link(ARGV[0], ARGV[1])' "$tmp" "$dest"
