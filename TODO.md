# TODO

Working list for `compact-tree-sitter`. Check items off as they land.

## Negative tests (must-fail cases)

tree-sitter corpus tests only assert successful parses, so we currently have no
automated guarantee that invalid Compact is rejected. `scripts/conformance.sh`
now locks the expected-failure set (regression gate), but an explicit
must-fail harness is still wanted:

- [ ] Add `test/negative/` with one `.compact` file per invalid construct
      (e.g. `experimental/reserved/`-style keywords, bad separators, malformed
      `type`/`import`/`assert`, unterminated strings).
- [ ] Add a script (e.g. `scripts/check-negative.mjs` or a shell script) that
      runs `tree-sitter parse` over `test/negative/**` and fails if any file
      parses without an `ERROR`/`MISSING` node.
- [ ] Wire it into CI (`.github/workflows/tests.yml`) as a separate step/job.
- [ ] Seed the corpus from the upstream negative fixtures:
      `examples/reserved/`, `examples/composable/`, and the
      `examples/bugs/` fuzz files (see `test/corpus` validation notes).
- [ ] Decide whether to keep the legacy `assert expr "msg";` statement form
      (superset) or remove it for strict 0.31.1 parsing.

## Upstream alignment

- [x] Bump Node deps to current upstream versions.
- [x] Bump Rust `dev-dependencies.tree-sitter`.
- [x] Add `path` / `highlights` to `tree-sitter.json`.
- [x] Fix `Makefile` fork URL and version.
- [ ] Migrate CI to the official actions:
      `tree-sitter/setup-action/cli@v2` + `tree-sitter/parser-test-action@v3`
      (replaces the bun-based test job) and add an `eslint` `lint.yml`.
- [ ] Optional: add `fuzz.yml` using `tree-sitter/fuzz-action@v4`.
- [ ] Optional: add `queries/tags.scm` and/or `queries/injections.scm` if
      editors need them, and register them in `tree-sitter.json`.

## Release follow-ups

- [x] Create the GitHub repo `1NickPappas/compact-tree-sitter` and push.
- [x] Add secret `CARGO_REGISTRY_TOKEN` (crates.io only for now).
- [x] Push tag `v0.1.0` to trigger the publish workflow (crate published).
- [ ] Later: enable npm/PyPI in `.github/workflows/publish.yml` and add
      `NPM_TOKEN` / `PYPI_API_TOKEN`.

## 0.2.0 consolidation (compiler-aligned grammar)

Target: a 0.2.0 that is at least as accurate as 0.1.0, uses compiler-aligned
node names, drops legacy constructs, and is gated by the conformance harness.
See the investigation notes: the WIP branch `feat/grammar-v0.30.0` targets the
0.30.0 language and is *not* authoritative; the compiler is.

- [x] Phase 0 — measuring sticks:
      `scripts/grammar-delta.sh` (compiler grammar diff between tags) and
      `scripts/conformance.sh` (parse the whole compiler corpus, baseline).
- [x] Phase 1 — renamed nodes to compiler names (`type_alias_declaration`,
      `slice_term`, `assert_term`, `assign_expr`, `spread_element`) and fixed
      the `struct_named_field_initializer` typo; conformance gate green.
- [x] Phase 2 — dropped legacy `edecl` and `assert_stmt` for strict 0.31.1
      support. No real 0.31.1 corpus file used them.
- [ ] Phase 3 — port the WIP branch corpus tests as *candidate inputs*,
      validating each against the 0.31.1 parser before keeping.
- [ ] Phase 4 — publish 0.2.0 (prepared; needs tag push).
- [ ] Optional: advertise `0.22.x–0.23.0` language support after verifying
      the near-identical 0.30.0 grammar passes the conformance gate.

## Tracking a moving language target

- [x] Track Compact toolchain releases and update the grammar + corpus when the
      language version bumps (current target: toolchain 0.31.1 / language
      0.23.0 / runtime 0.16.0).
- [x] Document the versioning policy: independent SemVer for the grammar with a
      README compatibility table and package metadata (`compact.language`,
      `compact.toolchain`).
- [ ] On each Compact language release, bump the grammar minor/major per the
      README table and record the new supported version.
