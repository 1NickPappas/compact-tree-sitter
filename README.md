# tree-sitter-compact

[![CI][ci]](https://github.com/1NickPappas/compact-tree-sitter/actions/workflows/tests.yml)
[![crates][crates]](https://crates.io/crates/tree-sitter-compact)

Compact grammar for [tree-sitter][].

This grammar parses the entire [Compact programming language][compact]. It is
based on the [formal grammar][grammar] published by the Midnight Foundation.

## Compatibility

This grammar targets Compact **language 0.23.0** and newer (toolchain
**0.31.1** and newer, runtime **0.16.0**), the version supported on Midnight
mainnet. Support starts at **0.31.1**: the grammar accepts the language as
defined by that toolchain and no longer accepts legacy syntax such as top-level
body-less `circuit` declarations or the old `assert expr "msg";` statement.
See the [compatibility matrix][support-matrix] for details.

| Grammar | Compact language | Compact toolchain |
|---------|------------------|-------------------|
| 0.2.x   | 0.23.0           | 0.31.1            |
| 0.1.x   | 0.23.0           | 0.31.1            |

The grammar follows independent [Semantic Versioning][semver]: the parse tree
is the public API, so adding nodes or fields is a minor release and breaking
tree changes are major. The supported Compact version is tracked in this table
and in the package metadata, not in the grammar version.

Grammars are validated against the compiler's own corpus with
[`scripts/conformance.sh`](scripts/conformance.sh); see
[`scripts/grammar-delta.sh`](scripts/grammar-delta.sh) for checking a new
Compact release.

## Fork

This repository is a community fork of
[`midnightntwrk/compact-tree-sitter`][upstream]. The upstream project is
archived and no longer maintained, so this fork is developed and maintained
independently.

It remains licensed under the [Apache License 2.0](LICENSE), the same license as
the upstream project. See [NOTICE](NOTICE) for attribution.

## Features

- **Incremental** — after an edit, tree-sitter updates the existing syntax tree
  and reuses the unchanged parts of it, so re-parsing is usually sub-millisecond.
- **Bindings** — first-class bindings for C, Go, Node.js, Python, Rust, and Swift.
- **Highlighting** — ships a `highlights.scm` query for syntax highlighting.
- **WASM** — can be compiled to WebAssembly for use in the browser and editors.

## Usage

### Node.js

```js
const Parser = require("tree-sitter");
const Compact = require("tree-sitter-compact");

const parser = new Parser();
parser.setLanguage(Compact);
```

### Rust

```toml
[dependencies]
tree-sitter = "0.25"
tree-sitter-compact = "0.1"
```

### Python

```python
import tree_sitter_compact
```

## References

- [The Compact Language Reference][compact]
- [The Compact formal grammar][grammar]

## License

[Apache License 2.0](LICENSE)

[tree-sitter]: https://github.com/tree-sitter/tree-sitter
[compact]: https://docs.midnight.network/develop/reference/compact/lang-ref
[grammar]: https://docs.midnight.network/develop/reference/compact/compact-grammar
[support-matrix]: https://docs.midnight.network/relnotes/support-matrix
[semver]: https://semver.org/spec/v2.0.0.html
[upstream]: https://github.com/midnightntwrk/compact-tree-sitter

[ci]: https://img.shields.io/github/actions/workflow/status/1NickPappas/compact-tree-sitter/tests.yml?logo=github&label=CI
[crates]: https://img.shields.io/crates/v/tree-sitter-compact?logo=rust
