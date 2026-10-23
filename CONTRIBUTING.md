# Contributing

Thanks for your interest in contributing to `compact-tree-sitter`! This is a
community-maintained [tree-sitter][tree-sitter] grammar for the
[Compact programming language][compact].

## Getting started

- **Review existing issues and pull requests** before submitting, to avoid
  duplicates.
- **Understand the grammar.** The grammar is defined in [`grammar.js`](grammar.js)
  and is based on the [Compact formal grammar][grammar].
- **Set up your development environment.** You will need
  [Node.js or Bun](https://nodejs.org/) and the `tree-sitter` CLI:

  ```sh
  npm install -g tree-sitter-cli
  ```

## Submitting issues

Use one of the [issue templates](.github/ISSUE_TEMPLATE) to report a bug, request
a feature, or suggest a documentation improvement. Please make the title a clear
summary and include enough context to reproduce or evaluate the request.

## Code contribution process

1. **Fork the repository** and create a branch for your change.
2. **Make your changes.** If you edit [`grammar.js`](grammar.js), regenerate the
   parser with `tree-sitter generate`.
3. **Add tests.** Grammar changes must include corpus tests under
   [`test/corpus/`](test/corpus). Run them with:

   ```sh
   tree-sitter test
   ```

4. **Follow existing style.** Keep commit messages clear and concise.
5. **Open a pull request** against `main` and be prepared to address review
   feedback.

## Requirements for acceptable contributions

- **Tests:** New or changed grammar functionality must include corresponding
  corpus tests.
- **Documentation:** Relevant changes should update the documentation.
- **License:** All contributions must be compatible with the project's license.
  By submitting a pull request you agree that your contribution is licensed
  under the [Apache License 2.0](LICENSE).

## Support and communication

Questions and discussion happen through
[GitHub issues](https://github.com/1NickPappas/compact-tree-sitter/issues) and
[pull requests](https://github.com/1NickPappas/compact-tree-sitter/pulls).

[tree-sitter]: https://tree-sitter.github.io/
[compact]: https://docs.midnight.network/develop/reference/compact/lang-ref
[grammar]: https://docs.midnight.network/develop/reference/compact/compact-grammar
