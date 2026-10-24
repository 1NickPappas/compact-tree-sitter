# Compatibility

Which `tree-sitter-compact` release to use, and what Compact version it
supports.

This grammar is versioned **independently** of the Compact toolchain (the parse
tree is the public API — see [Versioning policy](#versioning-policy)). The
supported Compact version is recorded as metadata, not in the grammar version.

## Supported versions

| Grammar | Compact language | Compact toolchain | Runtime         | Ledger |
|---------|------------------|-------------------|-----------------|--------|
| 0.3.x   | 0.23.0 – 0.27.0  | 0.31.1 – 0.35.0   | 0.16.0 – 0.20.0 | 8, 9   |
| 0.2.x   | 0.23.0           | 0.31.1            | 0.16.0          | 8      |
| 0.1.x   | 0.23.0           | 0.31.1            | 0.16.0          | 8      |

Support starts at Compact toolchain **0.31.1** (language 0.23.0). The grammar
does not accept legacy syntax such as top-level body-less `circuit`
declarations or the old `assert expr "msg";` statement.

## Which grammar for which network

The grammar is a **superset**: one release accepts the union of syntax across all
supported toolchains, so a single version serves every network line.

| Network            | Ledger | Compact toolchain | Grammar |
|--------------------|--------|-------------------|---------|
| Mainnet, Preview, Preprod (today) | 8 | 0.31.x | 0.3.x (or 0.2.x) |
| Ledger 9 (upcoming)               | 9 | 0.34.0 / 0.35.0 | 0.3.x |

Because 0.3.x also parses 0.31.1 code, **use the latest release** regardless of
network. Older grammar lines are kept only for reproducibility.

> **Note:** tree-sitter does **not** evaluate `pragma language_version`. The
> grammar accepts the superset and will happily parse `emit(...)` in a file that
> declares an older language version. Enforcing the language version is the
> Compact compiler's job, not the parser's. Use the grammar for parsing,
> highlighting, and editor tooling; use `compactc` for validation.

## Versioning policy

- **Grammar version** follows [Semantic Versioning](https://semver.org/) with the
  **parse tree as the public API**:
  - adding nodes/fields → minor release,
  - renaming or removing nodes → breaking (major; pre-1.0, a minor bump).
- **Compact support** is metadata: `compact.language`, `compact.toolchain`, and
  `compact.runtime` in `package.json`, `Cargo.toml`, and `pyproject.toml`, plus
  the table above. Bumping the supported Compact version does not by itself
  change the grammar version — only parse-tree changes do.

## Relationship to the compiler

The compiler at
[`LFDT-Minokawa/compact`](https://github.com/LFDT-Minokawa/compact) is the
source of truth for the language. This grammar is checked against the compiler's
own `.compact` corpus with
[`scripts/conformance.sh`](scripts/conformance.sh); the list of supported
compiler tags lives in
[`scripts/supported-versions.txt`](scripts/supported-versions.txt).

See [RELEASING.md](RELEASING.md) for how new Compact versions are staged,
tagged, and published.
