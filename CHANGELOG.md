# Changelog

All notable changes to this project will be documented in this file.

The format is inspired by common Ruby gem conventions.

---

## [0.1.0] - 2026-01-11
### Added
- Initial release of Ruex.
- Core DSL for generating HTML using plain Ruby expressions.
- Support for all standard HTML tags as Ruby methods.
- Attribute support via Ruby keyword arguments.
- Block syntax for nested HTML structures.
- `text` and `_` helpers for embedding raw text.
- Variable binding via `-b` / `--bind` CLI option.
- Context loading from YAML/JSON via `-c` / `--context-file`.
- CLI options for:
  - `-e` / `--expr` to evaluate inline expressions
  - `-f` / `--file` to read Ruex DSL from a file
  - `-I` to add load paths
  - `-r` to require custom tag libraries
- Support for custom tag modules (automatically included via `--require`).
- Programmatic API (`include Ruex` and `render` method).
- Documentation and examples in README.
- BSD 2-Clause license.

### Notes
- Ruex is intended for **static site or page generation** using trusted, developer-authored templates.
- It is **not suitable** as a dynamic web application renderer or for evaluating untrusted input.


