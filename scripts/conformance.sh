#!/usr/bin/env bash
#
# Conformance gate for compact-tree-sitter.
#
# Parses every .compact source file from a pinned LFDT-Minokawa/compact release
# with this grammar and fails if any file outside the known baseline does not
# parse. This is the acceptance test for grammar changes: it validates against
# the real language corpus (standard library, test-center, examples) rather
# than only hand-written corpus tests.
#
# Usage:
#   scripts/conformance.sh                     # run the gate
#   scripts/conformance.sh --update-baseline   # refresh the expected-failure list
#   scripts/conformance.sh <compiler-tag>      # use a specific compiler tag
#
# The pinned tag lives in scripts/compact-version.txt.
#
# Note: files are parsed one at a time on purpose. `tree-sitter parse` needs a
# prebuilt library (--lib-path) to avoid rebuild races, and its multi-file batch
# output silently drops some failures on large inputs.
#
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

compiler_repo="LFDT-Minokawa/compact"
default_tag="$(tr -d '[:space:]' < "$script_dir/compact-version.txt" 2>/dev/null || true)"
tag="$default_tag"
update_baseline="no"

while [ $# -gt 0 ]; do
  case "$1" in
    --update-baseline) update_baseline="yes" ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) tag="$1" ;;
  esac
  shift
done

if [ -z "$tag" ]; then
  echo "no compiler tag: set scripts/compact-version.txt or pass one" >&2
  exit 2
fi

cache_dir="${CONFORMANCE_CACHE:-$repo_root/.cache}"
src_dir="$cache_dir/compact-$tag"
baseline="$script_dir/conformance-baseline.txt"

# 1. Fetch and extract the compiler tree for the pinned tag, if not cached.
if [ ! -d "$src_dir" ]; then
  echo "==> fetching $compiler_repo@$tag"
  mkdir -p "$cache_dir"
  tarball="$cache_dir/$tag.tgz"
  if [ ! -f "$tarball" ]; then
    curl -fsSL "https://codeload.github.com/$compiler_repo/tar.gz/refs/tags/$tag" -o "$tarball"
  fi
  mkdir -p "$src_dir"
  tar xzf "$tarball" -C "$src_dir" --strip-components=1
fi

# 2. Build the parser once and locate the shared library.
echo "==> building parser"
tree-sitter build >/dev/null 2>&1 || { echo "tree-sitter build failed" >&2; exit 1; }
lib=""
for ext in so dylib dll; do
  if [ -f "parser.$ext" ]; then lib="$repo_root/parser.$ext"; break; fi
done
if [ -z "$lib" ]; then
  echo "could not find built parser library (parser.so / .dylib / .dll)" >&2
  exit 1
fi

# 3. Collect candidate files, excluding trees whose sources are intentionally
#    invalid (negative tests, fuzzing repros, reserved-word tests).
files=()
while IFS= read -r f; do
  files+=("$f")
done < <(find "$src_dir" -name '*.compact' \
  | grep -viE 'negative|failing|errors|reserved|invalid|reject|_error\.compact$' \
  | sort)

if [ "${#files[@]}" -eq 0 ]; then
  echo "no .compact files found under $src_dir" >&2
  exit 1
fi
echo "==> parsing ${#files[@]} files from $tag"

# 4. Parse one file at a time (see note at the top). A failing file produces a
#    non-empty summary line under -q.
failures_file="$(mktemp)"
baseline_sorted="$(mktemp)"
trap 'rm -f "$failures_file" "$baseline_sorted"' EXIT
for f in "${files[@]}"; do
  out="$(tree-sitter parse --lib-path "$lib" --lang-name compact -q "$f" 2>/dev/null || true)"
  if [ -n "$out" ]; then
    printf '%s\n' "${f#"$src_dir"/}" >> "$failures_file"
  fi
done
sort -u -o "$failures_file" "$failures_file"

if [ "$update_baseline" = "yes" ]; then
  if [ -s "$failures_file" ]; then
    cp "$failures_file" "$baseline"
    echo "==> wrote baseline: $baseline ($(wc -l < "$baseline" | tr -d ' ') entries)"
  else
    : > "$baseline"
    echo "==> wrote empty baseline: $baseline"
  fi
  exit 0
fi

if [ ! -f "$baseline" ]; then
  echo "no baseline at $baseline; run: scripts/conformance.sh --update-baseline" >&2
  exit 1
fi

sort "$baseline" > "$baseline_sorted"

new="$(comm -23 "$failures_file" "$baseline_sorted" || true)"
fixed="$(comm -13 "$failures_file" "$baseline_sorted" || true)"
bad="$(wc -l < "$failures_file" | tr -d ' ')"

echo "==> parsed ${#files[@]} files; $bad expected failures (baseline)"

if [ -n "$fixed" ]; then
  echo "note: these now parse and can be removed from the baseline:"
  printf '%s\n' "$fixed" | sed 's/^/    /'
fi

if [ -n "$new" ]; then
  echo "REGRESSIONS: files that used to parse now fail:" >&2
  printf '%s\n' "$new" | sed 's/^/    /' >&2
  exit 1
fi

echo "==> conformance OK"
