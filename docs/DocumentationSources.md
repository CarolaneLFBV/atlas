# Documentation sources — findings and policy

Last reviewed: 2026-10-28. This is a technical summary, not legal advice.

## Findings

1. **Apple offers no official public API** for its documentation catalogue.
2. **Every page on developer.apple.com has an undocumented JSON counterpart** at
   `https://developer.apple.com/tutorials/data/documentation/<path>.json`, and the catalogue is at
   `…/documentation/technologies.json`. The format is Swift-DocC *RenderNode* JSON, whose schema is
   public through the open-source [swift-docc](https://github.com/swiftlang/swift-docc) project.
   The endpoint itself is not a supported API and may change without notice.
3. **HTTP caching works**: responses carry `ETag`, `Last-Modified` and `Cache-Control: max-age=300`,
   and conditional requests (`If-None-Match`, `If-Modified-Since`) return `304 Not Modified`.
4. **There is no documentation update feed.** The developer news RSS feed covers general news only.
5. **Canonical links are derivable**: `doc://com.apple.SwiftUI/documentation/SwiftUI/View` maps to
   `https://developer.apple.com/documentation/swiftui/view`.
6. **Terms of use.** Each payload references the
   [Apple Website Terms of Use](https://www.apple.com/legal/internet-services/terms/site.html), which
   prohibit copying, republishing, displaying or distributing site content without Apple's express written
   consent, and prohibit robots, spiders or other automated means of accessing or copying the site.

7. **The Swift Programming Language** is published on docs.swift.org from the
   [swiftlang/swift-book](https://github.com/swiftlang/swift-book) repository, licensed under the
   **Apache License 2.0**. Its DocC JSON (`docs.swift.org/swift-book/data/…`) and navigator index
   (`docs.swift.org/swift-book/index/index.json`) support the same `ETag`/`Last-Modified` revalidation.

## Policy (as implemented)

| Source | Default | What Atlas does |
|---|---|---|
| The Swift Programming Language | On | Downloaded whole for offline reading and full-text search; rendered natively with the Apache 2.0 attribution on every page. |
| Swift 6 Concurrency Migration Guide | On | Same as above (swiftlang/swift-migration-guide, Apache 2.0). |
| Swift Evolution | On | All proposals (swiftlang/swift-evolution, Apache 2.0), from the official dashboard feed `download.swift.org/swift-evolution/v1/evolution.json` and the Markdown files. Each proposal's git SHA pins its cached copy: unchanged proposals are never re-downloaded. |
| Apple Developer Documentation | **Off** | developer.apple.com is **not contacted at all** — not even for the catalogue. The Library explains the source is off and links to the website. |

- The Apple source can be turned on in Settings (`SettingsKeys.appleContentFetchingEnabled`) for
  personal use. Requests then happen only when the user opens the Library or a page — no crawling,
  no background polling — and every page shows attribution and its canonical link.
- With the Apple source on, opening a framework page also loads that framework's navigator index
  (`/tutorials/data/index/<framework>`, one request per framework, revalidated at most weekly) so its
  whole API is searchable by name. Only titles and paths are indexed; pages are still fetched one at
  a time when opened, and Apple content is never downloaded in bulk or full-text indexed.
- Caching: catalogue revalidated after 24 h, pages and search indexes after 7 days, always with
  conditional requests; pull-to-refresh forces revalidation. A failed sync never deletes cached
  content, and offline reads show the cached copy labelled as offline.
- Search covers titles, symbols and keywords of every entry the app has seen, plus the **full text** of
  the downloaded open-license guides. Apple pages are never bulk-downloaded or full-text indexed.
  The search footer states exactly which sources are full-text searchable.
- Offline downloads run at launch when a guide was never downloaded or not checked for a week, one page
  at a time, with conditional requests; Settings shows progress and an "Update" button.
- No content is fabricated, and preview fixtures are always labelled as such.

To add another openly licensed DocC archive, implement `DocumentationSource` (a descriptor: URLs,
license, enabled state) and add it to `AppDependencies.liveSources()`.
