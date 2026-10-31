# Contributing to Atlas

Thanks for helping. A few things keep the project easy to read and safe to distribute.

## Before you start

- For anything larger than a small fix, open an issue first so we can agree on the approach.
- Read [ARCHITECTURE.md](ARCHITECTURE.md): it describes the layers and the conventions below.

## Conventions

- **One primary type per file**, named after the type. Extensions go in `Type+Purpose.swift`.
- **Folders by concept**, not by kind of file. Tests mirror the source tree.
- **Domain imports Foundation only.** SwiftUI, SwiftData and networking stay in their layers.
- **Comments explain why**, not what: constraints, workarounds, format rules, behavior a caller must know.
- **Design system first.** Use the tokens and components in `DesignSystem/` rather than literal colors, fonts or sizes.

## Content and licensing

- Never add documentation content to the repository.
- New documentation sources must be openly licensed for this use, display their license and attribution,
  and go through the `DocumentationSource` protocol.
- Don't add anything that contacts developer.apple.com by default.

## Tests

- Add or update unit tests (Swift Testing) for behavior you change.
- Run `atlasTests` before opening a pull request; tests must not use the network.

## Pull requests

- Keep them focused, and describe what changed and why.
- Don't commit signing changes (team or bundle identifier) or files from `xcuserdata/`.

By contributing, you agree that your contributions are licensed under the [Apache License 2.0](LICENSE).
