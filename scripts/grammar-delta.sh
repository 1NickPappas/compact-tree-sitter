#!/usr/bin/env bash
#
# Compare the Compact language grammar between two compiler tags.
#
# The Compiler is the source of truth for the language. This script fetches
# compiler/parser.ss, compiler/lexer.ss and doc/compact-grammar.mdx for two
# tags from LFDT-Minokawa/compact and reports the meaningful differences:
# production names, keyword groups, grammar-reference productions and lexer
# tokens. Use it whenever the supported Compact version is bumped so that new
# syntax is not missed (e.g. the 0.30.0 -> 0.31.1 `nat` -> `tsize` change in
# for-loop range bounds).
#
# Usage:
#   scripts/grammar-delta.sh <old-tag> <new-tag>
#
# Example:
#   scripts/grammar-delta.sh v0.30.0 compactc-v0.31.1
#
set -euo pipefail

old_tag="${1:?usage: grammar-delta.sh <old-tag> <new-tag>}"
new_tag="${2:?usage: grammar-delta.sh <old-tag> <new-tag>}"

repo="LFDT-Minokawa/compact"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache_dir="${DELTA_CACHE:-$script_dir/../.cache/delta}"

# Fetch a file for a tag into the cache (relative path preserved as filename).
fetch() { # tag file -> prints local path
  local tag="$1" file="$2" out
  out="$cache_dir/$tag/$(printf '%s' "$file" | tr '/' '_')"
  if [ ! -f "$out" ]; then
    mkdir -p "$(dirname "$out")"
    curl -fsSL "https://raw.githubusercontent.com/$repo/$tag/$file" -o "$out"
  fi
  printf '%s' "$out"
}

for tag in "$old_tag" "$new_tag"; do
  for file in compiler/parser.ss compiler/lexer.ss doc/compact-grammar.mdx; do
    fetch "$tag" "$file" >/dev/null
  done
done

old_dir="$cache_dir/$old_tag"
new_dir="$cache_dir/$new_tag"

section() { printf '\n### %s\n' "$1"; }
only_changes() { grep -E '^[<>]' || echo "(none)"; }

section "Production names added (>) / removed (<)"
diff \
  <(grep -oE '^[[:space:]]*\[[a-zA-Z][a-zA-Z0-9-]* ::' "$old_dir/compiler_parser.ss" | tr -d '[' | sed 's/[[:space:]]*//' | sort -u) \
  <(grep -oE '^[[:space:]]*\[[a-zA-Z][a-zA-Z0-9-]* ::' "$new_dir/compiler_parser.ss" | tr -d '[' | sed 's/[[:space:]]*//' | sort -u) \
  | only_changes || true

section "Keyword groups"
diff \
  <(sed -n '/define-keyword-group/,/keywordReservedForFutureUse/p' "$old_dir/compiler_parser.ss") \
  <(sed -n '/define-keyword-group/,/keywordReservedForFutureUse/p' "$new_dir/compiler_parser.ss") \
  | only_changes || true

section "Grammar-reference productions"
normalize() {
  sed -E 's/<[^>]*>//g; s/&xrarr;/->/g; s/\]\(#[^)]*\)/]/g; s/`[^`]*`/[K]/g; s/[[:space:]]+/ /g; s/^ //; s/ $//' "$1" \
    | grep '^|' | sort -u
}
diff <(normalize "$old_dir/doc_compact-grammar.mdx") <(normalize "$new_dir/doc_compact-grammar.mdx") \
  | grep -E '^[<>]' | grep -vE '^[<>] *\|?[-| ]+$' || echo "(none)"

section "Lexer"
diff "$old_dir/compiler_lexer.ss" "$new_dir/compiler_lexer.ss" \
  | grep -E '^[<>]' | grep -vE '^[<>] ;;;' || echo "(none)"

printf '\nDone.\n'
