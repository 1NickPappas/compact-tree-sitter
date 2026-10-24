# Releasing

How this repository tracks Compact releases and publishes grammar versions, with
the goal that a matching grammar is **already available when a Compact toolchain
goes live on a network**.

See [COMPATIBILITY.md](COMPATIBILITY.md) for the grammar→toolchain mapping and
the versioning policy.

## Version model

- The **grammar version** (`vX.Y.Z`) follows independent SemVer; the parse tree
  is the public API (additive → minor, breaking → major).
- The **supported Compact version** is metadata: `compact.language`,
  `compact.toolchain`, `compact.runtime` in `package.json`, `Cargo.toml`, and
  `pyproject.toml`, recorded as a range.
- Compact support and grammar version move **separately**: tracking a new
  toolchain that only adds syntax is a grammar minor bump.

## Branches

| Branch | Purpose |
|--------|---------|
| `main` | Newest superset grammar; the integration branch |
| `compact/<toolchain>` | Staging branch for an upcoming toolchain, e.g. `compact/0.35` |
| `maintenance/<line>` | Only when a line must be frozen (a future incompatible release) |

Work for an upcoming Compact version lands on `compact/<toolchain>` and merges to
`main` once green. Because the grammar is a superset, merging does not break
older networks.

## Tags

| Tag | Meaning |
|-----|---------|
| `vX.Y.Z` | Stable grammar release |
| `vX.Y.Z-rc.N` | Pre-release grammar, for staging ahead of go-live |

A `vX.Y.Z` tag must equal the version in `Cargo.toml` (the publish workflow
enforces this).

## Registry dist-tags

| Registry | Stable tag | Pre-release |
|----------|-----------|-------------|
| npm | `latest` | `next` (published with `--tag next`) |
| PyPI | normal release | PEP 440 pre-release (never `latest`) |
| crates.io | normal release | `-rc.N` pre-release (not selected by `cargo add` by default) |

Registry versions are **immutable** — never re-publish a version; bump and tag
again.

## Workflow: stage an upcoming Compact toolchain

Run this as soon as a toolchain reaches **stable** (or an RC, if you want an
early preview). Do not wait for network deployment.

1. `./scripts/grammar-delta.sh <current-tag> <new-tag>` — review production
   names, keyword groups, grammar-reference productions, and lexer changes.
2. Create the staging branch: `git switch -c compact/<toolchain>`.
3. Apply the grammar changes in `grammar.js`; add corpus tests under
   `test/corpus/` (name version-specific files, e.g. `release-0.35.txt`).
4. `npm run generate` and commit `src/`.
5. Add the new tag to `scripts/supported-versions.txt`.
6. Generate its baseline:
   `./scripts/conformance.sh <new-tag> --update-baseline`, then run
   `./scripts/conformance.sh <tag>` for **every** supported tag and confirm all
   are green.
7. Bump the grammar version per the policy (minor for additive syntax), update
   the metadata ranges, README table, `COMPATIBILITY.md`, and `CHANGELOG.md`.
8. Open a PR; require green Tests (parser + bindings), Lint, and the Conformance
   matrix.
9. Merge to `main`.
10. For an early preview, tag `vX.Y.Z-rc.1` and push it: npm publishes under
    `next`, PyPI/crates publish pre-releases.

## Workflow: promote to stable (go-live)

When the toolchain is deployed to a network (or you are confident it is safe):

1. Confirm `main` is green and the metadata range includes the new toolchain.
2. Tag `vX.Y.Z` and push it. This triggers:
   - `publish.yml` — GitHub release, crates.io, PyPI;
   - `publish-npm.yml` — npm.
3. Stable tags publish as `latest` on npm and as normal releases on PyPI/crates.
4. Update `COMPATIBILITY.md` if the network/ledger mapping changed.

Because the grammar is a superset, a stable release can go `latest` immediately
without breaking current ledger-8 users.

## Automation

- `scripts/supported-versions.txt` drives the **Conformance matrix**: CI runs
  `scripts/conformance.sh <tag>` for every supported tag, so new syntax never
  regresses an older line.
- `.github/workflows/watch-compact.yml` runs weekly, checks the compiler repo for
  a newer tag than the highest supported one, runs `grammar-delta.sh`, and opens
  (or comments on) an issue with the diff and the checklist above. That issue is
  the trigger to start the staging workflow.

## Release checklist

- [ ] `scripts/supported-versions.txt` updated
- [ ] `scripts/compact-version.txt` points at the newest supported tag
- [ ] per-tag baseline updated and conformance green for every supported tag
- [ ] `npm run generate` committed; `npm run lint` and `npm run test` green
- [ ] version bumped in all six files (`package.json`, `Cargo.toml`,
      `pyproject.toml`, `tree-sitter.json`, `Makefile`, `CMakeLists.txt`)
- [ ] metadata ranges, README table, `COMPATIBILITY.md`, `CHANGELOG.md` updated
- [ ] tag pushed; all four publish workflows green
