# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.31.1] - 2025-10-23

First release of the community-maintained fork. It targets the Compact
**toolchain 0.31.1** (language **0.23.0**, runtime **0.16.0**), which is the
version supported on Midnight mainnet.

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

[0.31.1]: https://github.com/1NickPappas/compact-tree-sitter/releases/tag/v0.31.1
