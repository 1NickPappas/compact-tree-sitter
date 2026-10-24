# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-10-24

Adds the syntax introduced by Compact toolchains 0.34.0 and 0.35.0. The grammar
now parses the language from toolchain 0.31.1 through 0.35.0 (language 0.23.0 –
0.27.0) as a single superset grammar, so one release serves both ledger 8
(mainnet today) and ledger 9 (upcoming).

### Added

- `contract implements <type>;` (`contract_implements_declaration`), from
toolchain 0.34.0.
- `emit(<expr>)` (`emit_term`), from toolchain 0.34.0.
- Compiler-accurate Unicode identifier categories: initial `Lu Ll Lt Lm Lo Nl`
(or `_`/`$`), with `Mn Mc Nd Pc` also allowed after the first character.

### Changed

- The supported Compact version is now recorded as a range in the package
metadata (`compact.language` = `>=0.23.0 <=0.27.0`, `compact.toolchain` =
`>=0.31.1 <=0.35.0`, `compact.runtime` = `>=0.16.0 <=0.20.0`) and in the
README/`COMPATIBILITY.md`.
- Conformance baselines are per compiler tag
(`scripts/conformance-baseline-<tag>.txt`), driven by
`scripts/supported-versions.txt`; the pinned tag is now `compactc-v0.35.0`.

> Note: tree-sitter does not evaluate `pragma language_version`. The grammar
> accepts the union of supported syntax; the Compact compiler remains the
> authority on version enforcement.

## [0.2.0] - 2025-10-23

Compiler-aligned grammar with stricter 0.31.1 semantics. This is a **breaking
release**: several node names changed and legacy syntax is no longer accepted.
Support starts at Compact toolchain 0.31.1 (language 0.23.0, runtime 0.16.0).

### Changed (breaking)

- Renamed nodes to match the compiler's AST / production names:
  - `type_decl` → `type_alias_declaration`
  - `slice_expr` → `slice_term`
  - `assert_expr` → `assert_term`
  - `assignment_expr` → `assign_expr`
  - `spread_expr` → `spread_element`
  - `struct_named_filed_initializer` → `struct_named_field_initializer`
    (typo fix)

### Removed (breaking)

- Top-level body-less `circuit id(...) : type;` declarations (`edecl`). This
  form is not part of the 0.31.1 grammar; declare a circuit with a body, or use
  `witness`.
- Legacy `assert expr "msg";` statement (`assert_stmt`). Use the
  `assert(expr, "msg")` expression instead.

### Added

- `scripts/conformance.sh` — parse the compiler corpus and fail on regressions
  against a baseline; also `scripts/grammar-delta.sh` for comparing two
  compiler releases. Both are wired into CI (Conformance workflow).

## [0.1.0] - 2025-10-23

First release of the community-maintained fork. It supports the Compact
**language 0.23.0** (toolchain **0.31.1**, runtime **0.16.0**), the version
supported on Midnight mainnet.

The grammar is versioned independently with [Semantic Versioning][semver]: the
parse tree is the public API, so node/field additions are minor releases and
breaking tree changes are major releases. The supported Compact version is
tracked in the README and in the package metadata, not in the grammar version.

### Added

- Grammar support for Compact 0.31.1:
  - `type` alias declarations: `export? new? type Name<gparams> = type;`
  - Import selections: `import { a, b as c } from name;`
  - `slice<N>(expr, expr)` expressions
  - `Bytes[...]` literals, including spread elements (`...`)
  - Spread elements in array literals: `[a, ...rest]`
  - `assert(condition, "message")` expressions
  - Multiple `const` bindings: `const a = 1, b = 2;`
  - Assignments used as expressions: `=`, `+=`, `-=`
  - Indexing by arbitrary expressions: `x[i + 1]`
  - `for` ranges with identifiers: `for (const i of start .. end)`
  - Binary, octal, and hexadecimal field literals (`0b`, `0o`, `0x`)
  - Unicode letters and `$` in identifiers
  - Block comments (`/* ... */`), escape sequences, and single-quoted strings
  - Comma-separated external-contract circuits with optional trailing separators
- Corpus tests covering every new construct.

### Changed

- Forked from `midnightntwrk/compact-tree-sitter`. The upstream project is
  archived, so this fork is now maintained independently at
  `1NickPappas/compact-tree-sitter`. Repository URLs and package metadata were
  updated to point at the fork.
- Struct declarations now accept comma-separated fields without a trailing
  comma, and semicolon-separated fields without a trailing semicolon.
- Expression sequences now accept two or more comma-separated expressions.

### Fixed

- `highlights.scm` no longer contains an impossible pattern that made query
  compilation fail.

[0.1.0]: https://github.com/1NickPappas/compact-tree-sitter/releases/tag/v0.1.0
[0.2.0]: https://github.com/1NickPappas/compact-tree-sitter/releases/tag/v0.2.0
[0.3.0]: https://github.com/1NickPappas/compact-tree-sitter/releases/tag/v0.3.0
[semver]: https://semver.org/spec/v2.0.0.html
