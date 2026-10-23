# tree-sitter-compact

[![CI][ci]](https://github.com/1NickPappas/compact-tree-sitter/actions/workflows/tests.yml)
[![crates][crates]](https://crates.io/crates/tree-sitter-compact)
[![npm][npm]](https://www.npmjs.com/package/tree-sitter-compact)
[![pypi][pypi]](https://pypi.org/project/tree-sitter-compact)

Compact grammar for [tree-sitter][].

This grammar parses the entire [Compact programming language][compact]. It is
based on the [formal grammar][grammar] published by the Midnight Foundation.

## Compatibility

This release targets Compact **toolchain 0.31.1** (language **0.23.0**,
runtime **0.16.0**), the version supported on Midnight mainnet. See the
[compatibility matrix][support-matrix] for details.

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
tree-sitter-compact = "0.31.1"
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
[upstream]: https://github.com/midnightntwrk/compact-tree-sitter

[ci]: https://img.shields.io/github/actions/workflow/status/1NickPappas/compact-tree-sitter/tests.yml?logo=github&label=CI
[crates]: https://img.shields.io/crates/v/tree-sitter-compact?logo=rust
[npm]: https://img.shields.io/npm/v/tree-sitter-compact?logo=npm
[pypi]: https://img.shields.io/pypi/v/tree-sitter-compact?logo=pypi&logoColor=ffd242
