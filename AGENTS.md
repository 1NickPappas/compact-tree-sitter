# AGENTS.md

Instructions for AI agents (and humans) working in this repository. Read this
before changing anything. It encodes the project's invariants, the canonical
commands, and the hard-won gotchas from past releases.

## What this project is

`tree-sitter-compact` is a community fork of the archived
`midnightntwrk/compact-tree-sitter` grammar for the
[Compact](https://docs.midnight.network/develop/reference/compact/lang-ref)
zero-knowledge smart-contract language. Upstream is unmaintained; this fork is
the maintained one.

- **Package name:** `tree-sitter-compact` (same on crates.io, npm, PyPI)
- **Grammar name:** `compact` (scope `source.compact`, file extension `.compact`)
- **License:** Apache-2.0 (see `NOTICE` for upstream attribution)
- **Repository:** https://github.com/1NickPappas/compact-tree-sitter
- **Current version:** `0.2.0`

### Supported Compact version

| Grammar | Compact language | Compact toolchain | Runtime         |
|---------|------------------|-------------------|-----------------|
| 0.3.x   | 0.23.0 – 0.27.0  | 0.31.1 – 0.35.0   | 0.16.0 – 0.20.0 |
| 0.2.x   | 0.23.0           | 0.31.1            | 0.16.0          |
| 0.1.x   | 0.23.0           | 0.31.1            | 0.16.0          |

Support **starts at toolchain 0.31.1**. The grammar is a single **superset**
covering every supported toolchain, so one release serves ledger 8 (mainnet
today) and ledger 9 (upcoming). Legacy syntax (top-level body-less `circuit`
declarations, the old `assert expr "msg";` statement) is intentionally **not**
accepted. Do not "helpfully" re-add legacy forms.

Tree-sitter does **not** evaluate `pragma language_version` — the grammar accepts
the union of supported syntax and the Compact compiler enforces the version. See
`COMPATIBILITY.md`.

### Versioning policy (important)

The grammar follows **independent SemVer**, because the **parse tree is the
public API**:

- Adding nodes/fields → **minor**
- Breaking tree changes (renames, removals) → **major** (pre-1.0: minor bump,
  as with 0.2.0)
- The supported Compact version is **metadata**, not the grammar version. Record
  it in the README table and in the package metadata (`package.json` `compact`,
  `[package.metadata.compact]`, `[tool.compact]`).

## Source of truth

**The Compact compiler wins**, not the WIP branch and not guesswork. When in
doubt, consult, in this order:

1. `compiler/parser.ss` and `compiler/lexer.ss` in
   [`LFDT-Minokawa/compact`](https://github.com/LFDT-Minokawa/compact) at the
   pinned tag.
2. `doc/compact-grammar.mdx` in the same repo.
3. Real `.compact` files from the compiler corpus (std lib, test-center,
   examples).

The branch `feat/grammar-v0.30.0` in this fork targets the 0.30.0 language and
is **not** authoritative. An audit found our 0.2.0 grammar parsed more real
files than that branch (355/384 vs 350/384) and failed nothing it passed.

## Repository map

| Path | Purpose |
|------|---------|
| `grammar.js` | The grammar definition — the only hand-written grammar source |
| `src/parser.c`, `src/grammar.json`, `src/node-types.json` | Generated; commit them |
| `test/corpus/*.txt` | Corpus tests (must all pass) |
| `queries/highlights.scm` | Syntax highlighting query |
| `scripts/compact-version.txt` | Default/pinned compiler tag (`compactc-v0.35.0`) |
| `scripts/supported-versions.txt` | All supported compiler tags; drives the conformance matrix |
| `scripts/conformance.sh` | Parse a compiler corpus; per-tag regression gate |
| `scripts/conformance-baseline-<tag>.txt` | Expected-failure list, one per compiler tag |
| `scripts/grammar-delta.sh` | Diff the language grammar between two compiler tags |
| `COMPATIBILITY.md` | Grammar→toolchain→network mapping and versioning policy |
| `RELEASING.md` | Branch/tag/staging conventions and the release process |
| `.github/workflows/tests.yml` | Official tree-sitter parser + binding tests (Rust/Python/Go/Swift) |
| `.github/workflows/lint.yml` | ESLint (`eslint-config-treesitter`) |
| `.github/workflows/conformance.yml` | Conformance matrix over all supported tags (push/PR/weekly) |
| `.github/workflows/watch-compact.yml` | Weekly check for new compiler releases; opens an issue |
| `.github/workflows/publish.yml` | GitHub release + crates.io + PyPI |
| `.github/workflows/publish-npm.yml` | npm (dedicated; see gotchas) |
| `.github/workflows/scan.yaml` | Trivy vulnerability/secret scan |
| `bindings/` | C, Go, Node, Python, Rust, Swift bindings |

## Canonical dev loop

```sh
npm ci                    # install deps (package-lock.json is committed)
npm run generate          # regenerate src/ from grammar.js — always run after editing grammar.js
npm run lint              # eslint grammar.js
npm run test              # tree-sitter test (corpus)
./scripts/conformance.sh  # parse the real compiler corpus
```

All four must pass before a PR is mergeable. `npm run generate` output must be
committed; CI fails if `src/` is stale (`git diff --exit-code src/`).

## Workflow: changing the grammar

1. Edit `grammar.js`.
2. Add/update corpus tests in `test/corpus/`. Every grammar change needs tests;
   new syntax gets a new fixture file (see the `release-*.txt` naming used for
   version-specific coverage).
3. `npm run generate` and commit `src/`.
4. `npm run lint`, `npm run test`, `./scripts/conformance.sh`.
5. If a conformance file now parses that did not before, remove it from
   `scripts/conformance-baseline-<tag>.txt` (the script prints these as "fixed").
   If a file that used to parse now fails, that is a **regression** — fix the
   grammar or explicitly justify a baseline addition in the PR.
6. Update `CHANGELOG.md` and bump the version per the policy above if this is a
   release.

## Workflow: tracking a new Compact release

1. Run `./scripts/grammar-delta.sh <old-tag> <new-tag>` to see production names,
   keyword groups, grammar-reference productions, and lexer changes.
2. Update the grammar for the new syntax; add corpus tests.
3. Add the tag to `scripts/supported-versions.txt`, set
   `scripts/compact-version.txt` to it, and run
   `./scripts/conformance.sh <tag> --update-baseline`. Refresh the baseline only
   for genuinely-invalid upstream files, never to hide regressions.
4. Run `./scripts/conformance.sh <tag>` for **every** supported tag and confirm
   all pass (this is what the CI conformance matrix does).
5. Update the metadata ranges, README/`COMPATIBILITY.md`, and CHANGELOG; bump the
   grammar version per the SemVer policy. See `RELEASING.md` for the full flow.

## Workflow: releasing

The version lives in **six** tracked files — update all of them together (a past
release missed `CMakeLists.txt`):

- `package.json` (`version`)
- `Cargo.toml` (`[package] version`)
- `pyproject.toml` (`[project] version`)
- `tree-sitter.json` (`metadata.version`)
- `Makefile` (`VERSION :=`)
- `CMakeLists.txt` (`project(... VERSION ...)`)

Sanity check: `git grep -n '0\.3\.0' -- . ':!package-lock.json' ':!test' ':!*.md' ':!scripts'`
should list only those six. Note the version is also embedded in
`src/parser.c` — run `npm run generate` after bumping.

See `RELEASING.md` for the full staging/promotion flow.

Then:

1. Update `CHANGELOG.md` (Keep a Changelog format) and the README table.
2. Commit, tag `vX.Y.Z`, push the tag. The tag **must** equal `Cargo.toml`'s
   version or the publish workflow's verify job fails.
3. Tag pushes run `publish.yml` (GitHub release, crates.io, PyPI) and
   `publish-npm.yml` (npm). A `vX.Y.Z-rc.N` tag publishes a pre-release: npm
   goes to the `next` dist-tag and PyPI/crates publish pre-releases. See
   `RELEASING.md`.
4. To publish a single registry for an already-tagged version, dispatch
   manually:

   ```sh
   gh workflow run publish.yml --ref main \
     -f skip-crates=true -f skip-github-release=true -f skip-pypi=true
   gh workflow run publish-npm.yml --ref main
   ```

Registry versions are **immutable** — you cannot republish a version. Bump and
re-tag instead. `0.1.0`, `0.2.0`, and `0.3.0` are published on all three.

## Verification gates

| Gate | Command | Must be |
|------|---------|---------|
| Corpus tests | `npm run test` | 154/154 (grows with new tests) |
| Lint | `npm run lint` | clean |
| Generated files | `npm run generate && git diff --exit-code src/` | no diff |
| Conformance | `./scripts/conformance.sh <tag>` for each supported tag | "conformance OK" |
| Node types | named types in `src/node-types.json` | all reachable/covered |

## Gotchas (learned the hard way — do not rediscover)

### Conformance script

- **Parse one file at a time.** `tree-sitter parse -q` given multiple files
  silently drops some failures on large batches. The script loops deliberately.
- **Use a prebuilt library.** Build once with `tree-sitter build`, then parse
  with `--lib-path <repo>/parser.{so,dylib,dll}`. Parsing per-file without a
  prebuilt lib races on rebuilds.
- **Clear the CLI cache if the wrong grammar loads.** The CLI caches compiled
  parsers by language name at `~/.cache/tree-sitter/lib/compact.dylib`. The WIP
  branch also uses the name `compact`, so a stale cache can mask changes.
  `rm -rf ~/.cache/tree-sitter/lib` when results look impossible.
- Baselines are **per compiler tag** (`scripts/conformance-baseline-<tag>.txt`),
  so a multi-version matrix can check each line against its own set. The list of
  tags is `scripts/supported-versions.txt`.
- The script excludes intentionally-invalid trees (`negative`, `failing`,
  `errors`, `reserved`, `invalid`, `reject`, `_error.compact`). Keep those
  exclusions when adding fixtures.

### npm publishing

- **`package-lock.json` must stay committed and un-ignored.** The npm workflows
  use `actions/setup-node` with `cache: npm`, which requires a lockfile. Upstream's
  `.gitignore` excluded it; that broke CI. Do not re-add `package-lock.json` to
  `.gitignore`.
- The project uses **npm**, not bun. `bun.lock` was removed.
- **We do not use the reusable `tree-sitter/workflows` npm workflow.** Its matrix
  includes `windows-11-arm`, where `node-gyp` cannot detect the runner's Visual
  Studio 18; the build fails and the whole publish is skipped. `publish-npm.yml`
  is a dedicated workflow with a controlled matrix (no `windows-11-arm`); Windows
  arm64 falls back to a source build via `node-gyp-build`.
- npm briefly shows a `0.0.0-stage` placeholder while a publish is processed.
  It resolves to the real version within a couple of minutes. It is not an error.
- npm is restricting 2FA-bypass tokens for direct publishing (targeted Jan 2027).
  Future-proofing means npm **trusted publishing (OIDC)**; see `TODO.md`.

### crates.io

- The license field must be a valid SPDX expression: `Apache-2.0`, not `Apache`.
- crates.io requires a verified email on the account.
- The published crate compiles the **committed** `src/parser.c`, so it must be in
  sync with `grammar.js` (an earlier release shipped stale generated files; the
  verify job now guards this).
- **The crates job runs with `generate: false`.** The reusable package-crates
  workflow regenerates with the *latest* tree-sitter CLI, whose output differs
  from the pinned `v0.26.13` parser we commit; with `generate: true` that leaves
  `src/parser.c` dirty and `cargo publish` aborts. The `verify` job already
  checks `src/` is current with the pinned CLI, so publish the committed files.

### GitHub Actions

- The repo is a fork, so Actions were disabled initially. If workflows do not
  run, check `gh api repos/1NickPappas/compact-tree-sitter/actions/permissions`.
- The publish workflow is gated by `workflow_dispatch` inputs `skip-crates`,
  `skip-github-release`, and `skip-pypi`.
- PyPI's reusable workflow warns that `attestations: true` is ignored when an
  explicit password/token is set. That is expected while using `PYPI_API_TOKEN`.

### CI and the official tree-sitter actions

- `tests.yml` uses the official `tree-sitter/setup-action/cli@v2` plus
  `tree-sitter/parser-test-action@v3`, which regenerates and verifies
  `src/parser.c`, runs the corpus tests, and runs the Rust/Python/Go/Swift
  binding tests.
- **The CLI ref is pinned (`tree-sitter-ref: v0.26.13`)** so the "generated
  parser is current" check compares against the same release that generated the
  committed `src/parser.c`. If you regenerate with a different CLI version,
  bump the pinned ref in `tests.yml` and `conformance.yml` together.
- The action's generate check only diffs `src/parser.c`, not `grammar.json` or
  `node-types.json`; keep those in sync by running `npm run generate`.
- `eslint` lives in `lint.yml` because `parser-test-action` does not lint.
- `tree-sitter-ref` values starting with `v` download a prebuilt CLI release
  (fast); anything else is built from source with Cargo.
- `conformance.yml` reads `scripts/supported-versions.txt` and runs the gate for
  every supported tag (one matrix job each). `watch-compact.yml` runs weekly,
  compares the latest stable compiler tag to the highest supported one, and opens
  a tracking issue with the grammar delta when there is a newer one.
- `publish-npm.yml` takes a `dist-tag` input; tag pushes containing `-` publish
  under `next` automatically (pre-releases).

### Swift binding

- `Package.swift` must declare the external product explicitly:
  `.product(name: "SwiftTreeSitter", package: "swift-tree-sitter")`. A bare
  `"SwiftTreeSitter"` fails SwiftPM resolution.
- The Swift test needs a full toolchain with `XCTest`; a CommandLineTools-only
  macOS cannot run it locally even though CI can.

### Corpus tests

- tree-sitter corpus tests only assert **successful** parses. There is currently
  no must-fail harness, so invalid input is not automatically rejected in CI.
  `scripts/conformance.sh` is the regression gate for real files. A negative-test
  harness is an open TODO — do not assume one exists.

## Secrets and publishing

Secrets are set in GitHub → Settings → Secrets and variables → Actions. Agents
must never request or handle secret values; users create tokens and add them.

| Secret | Registry | Notes |
|--------|----------|-------|
| `CARGO_REGISTRY_TOKEN` | crates.io | Already set |
| `NPM_TOKEN` | npm | Already set |
| `PYPI_API_TOKEN` | PyPI | Already set; replace with a project-scoped token now that the project exists |

## Project constraints and preferences

- **GitHub-only contact.** Do not publish a personal email address anywhere in
  the repo or package metadata. Use GitHub URLs.
- **No secrets in the repo.** Ever.
- **Keep the published parse tree stable.** Renames/removals are breaking
  changes and need a version bump plus a CHANGELOG entry.
- **Do not "fix" the strictness.** Legacy Compact syntax is dropped on purpose.
- **Do not treat the WIP branch as authoritative.** The compiler is.
- **Update docs with code.** README table, CHANGELOG, and package metadata move
  together with grammar changes.

## Open work (see `TODO.md` for the full list)

- Negative-test harness (`test/negative/` + a script + CI wiring).
- Migrate CI to the official `tree-sitter/parser-test-action@v3`.
- Optional `fuzz.yml`, `queries/tags.scm`, `queries/injections.scm`.
- npm trusted publishing (OIDC) to replace the token before the 2FA change.
- Optionally advertise `0.22.x–0.23.0` support after verifying 0.30.0 corpus.
