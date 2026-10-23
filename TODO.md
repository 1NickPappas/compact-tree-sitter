# TODO

Working list for `compact-tree-sitter`. Check items off as they land.

## Negative tests (must-fail cases)

tree-sitter corpus tests only assert successful parses, so we currently have no
automated guarantee that invalid Compact is rejected. Add a small harness:

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

- [ ] Create the GitHub repo `1NickPappas/compact-tree-sitter` and push.
- [ ] Add secrets: `NPM_TOKEN`, `CARGO_REGISTRY_TOKEN`, `PYPI_API_TOKEN`.
- [ ] Push tag `v0.31.1` to trigger the publish workflow.

## Tracking a moving language target

- [ ] Track Compact toolchain releases and update the grammar + corpus when the
      language version bumps (current target: toolchain 0.31.1 / language
      0.23.0 / runtime 0.16.0).
- [ ] Add a doc note mapping grammar releases to Compact versions.
