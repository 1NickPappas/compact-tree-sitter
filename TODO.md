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
- [x] Decided: the legacy `assert expr "msg";` form was removed in 0.2.0; the
      grammar is strict about dropped syntax.

## Upstream alignment

- [x] Bump Node deps to current upstream versions.
- [x] Bump Rust `dev-dependencies.tree-sitter`.
- [x] Add `path` / `highlights` to `tree-sitter.json`.
- [x] Fix `Makefile` fork URL and version.
- [x] Migrate CI to the official actions:
      `tree-sitter/setup-action/cli@v2` + `tree-sitter/parser-test-action@v3`.
      CLI pinned to `v0.26.13` to match the committed `src/parser.c`. Binding
      tests enabled for Rust, Python, Go, and Swift. Added an `eslint`
      `lint.yml`.
      - [x] Fixed `Package.swift` (external product must be declared as
            `.product(name: "SwiftTreeSitter", package: "swift-tree-sitter")`)
            so the Swift binding/tests actually build.
      - [ ] Optional: add a Node binding test (`bindings/node/*_test.js`) so
            `test-node` can be enabled too.
- [ ] Optional: add `fuzz.yml` using `tree-sitter/fuzz-action@v4`.
- [ ] Optional: add `queries/tags.scm` and/or `queries/injections.scm` if
      editors need them, and register them in `tree-sitter.json`.

## Build toolchain (tree-sitter generator)

The tree-sitter CLI is a **build tool whose output we commit**
(`src/parser.c`, `grammar.json`, `node-types.json`). It is pinned to the exact
version that produced the committed files (`tree-sitter-cli` 0.26.13, i.e. the
newest 0.26.x patch). Do not chase `latest` — the generated output is not stable
across versions, so a mismatch breaks the "generated parser is current" CI check
and `cargo publish`. Upgrade deliberately, with a reason or on a slow cadence.

- [ ] Bump the generator when warranted (e.g. 0.26.13 -> 0.27.x). Steps:
      update `tree-sitter-cli` in `package.json`, `npm install`, `npm run
      generate` and commit `src/`, run `npm run lint`/`npm run test` and
      `./scripts/conformance.sh <tag>` for **every** supported tag, and move the
      pinned `tree-sitter-ref` in `tests.yml` and `conformance.yml` to match.
      Confirm `#define LANGUAGE_VERSION` is still 15 (or bump the runtime
      requirements if the ABI changed).
- [ ] Guard automation: Renovate is enabled and will open npm PRs; a
      `tree-sitter-cli` bump PR fails CI because the regenerated `src/` no
      longer matches the committed file. Ignore `tree-sitter-cli` in
      `renovate.json` (a `packageRules` `matchPackageNames` ignore), or adopt the
      upstream `tree-sitter/workflows/.github/workflows/regenerate.yml`
      workflow to auto-regenerate on those PRs.
- [ ] Optional: adopt the upstream `regenerate.yml` reusable workflow so the
      generator and `src/` stay in lockstep automatically.

## Release follow-ups

- [x] Create the GitHub repo `1NickPappas/compact-tree-sitter` and push.
- [x] Add secret `CARGO_REGISTRY_TOKEN` (crates.io only for now).
- [x] Push tag `v0.1.0` to trigger the publish workflow (crate published).
- [x] Enabled PyPI (in `publish.yml`) and npm (dedicated `publish-npm.yml`).
- [x] Added `NPM_TOKEN` / `PYPI_API_TOKEN`; published 0.2.0 to npm and PyPI.
- [ ] Consider npm trusted publishing (OIDC) or accepted staged publishing for
      future releases; npm is restricting 2FA-bypass tokens for direct publish.

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
- [x] Phase 3 — audited the WIP branch corpus: all 159 inputs parse with the
      0.2.0 grammar, so porting its 0.30-era expected trees adds no acceptance
      coverage. Skipped; the conformance gate is the coverage guard.
- [x] Phase 4 — published 0.2.0 (crates.io + GitHub release).
- [x] Superseded: 0.3.x advertises Compact language 0.23.0–0.27.0 (toolchain
      0.31.1–0.35.0) as a single superset grammar.

## 0.3.0 — Compact 0.34.0 / 0.35.0 support

Target: parse the language introduced by toolchain 0.34.0 (language 0.26.0) and
0.35.0 (language 0.27.0) without regressing the 0.31.1 (mainnet) line. The two
releases are grammar-identical; all new syntax (`implements`, `emit`, identifier
categories) landed at once.

- [x] Added `contract implements <type>;` (`contract_implements_declaration`).
- [x] Added `emit(<expr>)` (`emit_term`).
- [x] Compiler-accurate Unicode identifier categories (initial `Lu Ll Lt Lm Lo
      Nl`, subsequent adds `Mn Mc Nd Pc`).
- [x] Per-tag conformance baselines (`scripts/conformance-baseline-<tag>.txt`) +
      `scripts/supported-versions.txt`; conformance green for 0.31.1 and 0.35.0.
- [x] Conformance matrix in CI and a weekly `watch-compact.yml` tracking issue.
- [x] `COMPATIBILITY.md` and `RELEASING.md`; metadata records a supported range.
- [x] Published 0.3.0 to crates.io, npm, and PyPI, plus GitHub release v0.3.0.

Note: the grammar is a superset and does **not** evaluate `pragma
language_version`; the compiler enforces the version. See `COMPATIBILITY.md`.

## Tracking a moving language target

- [x] Track Compact toolchain releases and update the grammar + corpus when the
      language version bumps (current target: toolchain 0.31.1 / language
      0.23.0 / runtime 0.16.0).
- [x] Document the versioning policy: independent SemVer for the grammar with a
      README compatibility table and package metadata (`compact.language`,
      `compact.toolchain`).
- [x] On each Compact language release, bump the grammar minor/major per the
      README table and record the new supported version. (0.34.0/0.35.0 done in
      0.3.0; the weekly `watch-compact.yml` opens an issue for the next one.)
