# Atlas — Architecture

Atlas is a native iOS, iPadOS and macOS companion for exploring Apple-platform developer documentation.
This document describes how the code is organized and the conventions contributors follow.

## Layers

The app follows Clean Architecture with MVVM in the presentation layer. Dependencies point inward:

```
App ──▶ Presentation ──▶ Domain ◀── Data
             │                        ▲
             └──▶ DesignSystem        │
App ──────────────────────────────────┘ (composition only)
```

| Layer | Folder | Responsibility | May import |
|---|---|---|---|
| Domain | `atlas/Domain` | Entities, repository protocols, use cases, pure logic (search ranking) | Foundation only |
| Data | `atlas/Data` | Networking, DocC decoding, SwiftData persistence, SQLite search indexes, repository implementations | Foundation, SwiftData, SQLite3, OSLog |
| DesignSystem | `atlas/DesignSystem` | Tokens and reusable, data-agnostic UI components | SwiftUI |
| Presentation | `atlas/Presentation` | One folder per feature: views, view models, feature components | SwiftUI, Observation |
| App | `atlas/App` | Entry point, dependency composition, root navigation, configuration | Everything |

Rules:

- **Domain never imports SwiftUI, SwiftData or URLSession.** It defines protocols that Data implements.
- **Views render and forward intent.** Business rules live in use cases; coordination lives in view models.
- **DTOs never leave Data.** Network and persistence types are mapped to domain entities first.
- **Dependencies are injected through initializers.** `AppDependencies` is the single composition root.
  There are no global singletons and no third-party DI or architecture frameworks.

## Folder conventions

- **One primary type per file**, and the file is named after it (`DocumentationID.swift`).
  Small nested types that only make sense inside their parent (e.g. `Declaration.Token`) stay nested.
- **Extensions** that add API to an existing type are named `Type+Purpose.swift` (`Font+AtlasStyles.swift`).
- **View modifiers** live in `DesignSystem/Modifiers`, one modifier per file, with its `View` convenience
  method in the same file.
- **Folders group by concept**, not by kind of Swift construct: `Domain/Entities/Pages`, `Data/Network`, …
- **Tests mirror the source tree** in `atlasTests`, one suite per file (`DocumentationIDTests.swift`).
  Shared fixtures are in `atlasTests/Support`, fakes in `atlasTests/TestDoubles`.

```
atlas/
├── App/            Launch · Composition · Configuration · Navigation
├── Domain/         Entities · Repositories · UseCases · Search · Results · Errors
├── Data/           Network · Sources · Parsing · DocC · Evolution · Markdown · Cache · Search
│                   Persistence (Models, Store) · Repositories
├── DesignSystem/   Foundations · Symbols · Components · Modifiers · Platform · Previews
└── Presentation/   Shared (Stores, Navigation, Components, Formatting, PreviewSupport)
                    Library · Search · DocumentationDetail · Saved · Settings
atlasTests/         mirrors atlas/ · Support · TestDoubles
```

## Presentation conventions

- Each screen has a view model (`LibraryViewModel`, `SearchViewModel`, …) created with its use cases.
- State shared by several screens at once (bookmarks, snippets, history) lives in `@Observable`
  stores in `Presentation/Shared/Stores`, injected through the environment.
- Views never decide *how* to navigate: they call the `openDocumentation` environment action.
  On iPhone it pushes onto the tab's stack; on iPad and Mac it replaces the reading pane.
- Preview data lives in `Presentation/Shared/PreviewSupport`, is labelled as fixtures and is never
  used by the running app.

## Concurrency

The app target uses Swift 6 with `MainActor` default isolation. Value types that cross isolation
domains (domain entities, network types) are explicitly `nonisolated` and `Sendable`. User content
(bookmarks, snippets, history) uses the container's main context, since screens observe it directly.
The network cache (`CachedResourceStore`) is a `@ModelActor` with its own background context, so
megabyte payloads are read and written off the main thread. DocC decoding and mapping run off the main
actor (`DocCParser`, `@concurrent`). Search indexes are actors (`SearchIndexStore`, `FullTextIndexStore`),
so indexing and querying never block the interface.

## Stored formats

Domain types are never written to disk as they are. Entries saved in bookmarks, history and the
search indexes use `StoredEntry` (`Data/Persistence/Store`): a versioned format with stable kind codes,
mapped to and from `DocumentationEntry`. Renaming a domain property only changes the mapping.

- New fields are optional, so older payloads keep decoding; unknown kind codes read as `.unknown`.
- `EntryPayloadCoder` reads every version ever written. Payloads from before the format existed
  (version 0) are rewritten in the current format the first time they're read.
- A payload from a newer app version is skipped (and logged), never misread or deleted.

## Search storage

User data (bookmarks, snippets, history) and the network cache live in SwiftData. The search indexes are
derived data and live in their own SQLite files (`Application Support/SearchIndexes`), behind a minimal
wrapper in `Data/Search/SQLite`:

- Titles are matched through a B-tree index (exact, then prefix); other metadata and page text through
  FTS5 with the trigram tokenizer, so substring queries ("@concurrent") use an index instead of a scan.
- Each index has a schema version. When it changes, the index is dropped and rebuilt from the cache and
  from what the app reads (no migration code); bulk resources such as framework indexes are re-indexed
  from the cache, without a request.
- An index that can't be opened is deleted and recreated, so a corrupt index never blocks the launch.

## Documentation sources

The data layer reads documentation through the `DocumentationSource` protocol, so the source can change
without touching the UI. A source is a descriptor (URLs, license, format); `SourceParser` picks the parser
for its `SourceFormat` (DocC or Swift Evolution), so caching, search and offline download are shared by all. What the app may display is decided per source by `RenderingPermission`.
See [`docs/DocumentationSources.md`](docs/DocumentationSources.md) for the legal and technical findings
behind this design.
