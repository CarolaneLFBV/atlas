import Foundation

/// Test data only.
enum DocCFixtures {
    static let symbolPage = Data(#"""
    {
      "identifier": { "url": "doc://com.example.TestKit/documentation/TestKit/Widget", "interfaceLanguage": "swift" },
      "kind": "symbol",
      "metadata": {
        "title": "Widget", "role": "symbol", "roleHeading": "Structure", "symbolKind": "struct",
        "modules": [{ "name": "TestKit" }],
        "platforms": [{ "name": "iOS", "introducedAt": "17.0" }, { "name": "macOS", "introducedAt": "14.0", "beta": true }]
      },
      "abstract": [{ "type": "text", "text": "A fixture " }, { "type": "codeVoice", "code": "struct" }, { "type": "text", "text": "." }],
      "primaryContentSections": [
        { "kind": "declarations", "declarations": [{ "languages": ["swift"], "tokens": [
          { "kind": "keyword", "text": "struct" }, { "kind": "text", "text": " " },
          { "kind": "identifier", "text": "Widget" }, { "kind": "text", "text": " : " },
          { "kind": "typeIdentifier", "text": "View", "identifier": "doc://com.example.TestKit/documentation/TestKit/View" }
        ] }] },
        { "kind": "mentions", "mentions": [] },
        { "kind": "content", "content": [
          { "type": "paragraph", "inlineContent": [{ "type": "text", "text": "Intro " }, { "type": "reference", "identifier": "doc://com.example.TestKit/documentation/TestKit/View", "isActive": true }] },
          { "type": "heading", "level": 2, "text": "Usage", "anchor": "usage" },
          { "type": "codeListing", "syntax": "swift", "code": ["let w = Widget()", "print(w)"] },
          { "type": "aside", "style": "warning", "name": "Warning", "content": [{ "type": "paragraph", "inlineContent": [{ "type": "emphasis", "inlineContent": [{ "type": "text", "text": "Careful" }] }] }] },
          { "type": "unorderedList", "items": [{ "content": [{ "type": "paragraph", "inlineContent": [{ "type": "text", "text": "One" }] }] }] },
          { "type": "table", "rows": [] },
          { "type": "paragraph", "inlineContent": [{ "type": "futureInlineType", "value": 1 }, { "type": "text", "text": "Still readable" }] }
        ] }
      ],
      "topicSections": [{ "title": "Essentials", "identifiers": ["doc://com.example.TestKit/documentation/TestKit/View", "doc://missing/reference"] }],
      "relationshipsSections": [{ "title": "Conforms To", "type": "conformsTo", "identifiers": ["doc://com.example.TestKit/documentation/TestKit/View"] }],
      "references": {
        "doc://com.example.TestKit/documentation/TestKit/View": {
          "type": "topic", "identifier": "doc://com.example.TestKit/documentation/TestKit/View",
          "title": "View", "kind": "symbol", "role": "symbol", "url": "/documentation/testkit/view",
          "abstract": [{ "type": "text", "text": "A fixture protocol." }]
        },
        "image.png": { "type": "image", "identifier": "image.png" }
      }
    }
    """#.utf8)

    static let deprecatedPage = Data(#"""
    {
      "identifier": { "url": "doc://com.example.TestKit/documentation/TestKit/OldView" },
      "kind": "symbol",
      "metadata": {
        "title": "OldView", "role": "symbol", "symbolKind": "struct", "modules": [{ "name": "TestKit" }],
        "platforms": [{ "name": "iOS", "introducedAt": "13.0", "deprecatedAt": "18.0", "message": "use NewView instead" }]
      },
      "deprecationSummary": [{ "type": "paragraph", "inlineContent": [
        { "type": "text", "text": "Use " },
        { "type": "reference", "identifier": "doc://com.example.TestKit/documentation/TestKit/NewView", "isActive": true },
        { "type": "text", "text": " instead." }
      ] }],
      "topicSections": [{ "title": "Related", "identifiers": [
        "doc://com.example.TestKit/documentation/TestKit/NewView",
        "doc://com.example.TestKit/documentation/TestKit/OlderView"
      ] }],
      "references": {
        "doc://com.example.TestKit/documentation/TestKit/NewView": {
          "type": "topic", "identifier": "doc://com.example.TestKit/documentation/TestKit/NewView",
          "title": "NewView", "kind": "symbol", "role": "symbol", "url": "/documentation/testkit/newview"
        },
        "doc://com.example.TestKit/documentation/TestKit/OlderView": {
          "type": "topic", "identifier": "doc://com.example.TestKit/documentation/TestKit/OlderView",
          "title": "OlderView", "kind": "symbol", "role": "symbol", "url": "/documentation/testkit/olderview", "deprecated": true
        }
      }
    }
    """#.utf8)

    /// Deprecated on one platform only, with no summary: not a deprecated page.
    static let partlyDeprecatedPage = Data(#"""
    {
      "identifier": { "url": "doc://com.example.TestKit/documentation/TestKit/Partial" },
      "kind": "symbol",
      "metadata": {
        "title": "Partial", "role": "symbol", "symbolKind": "func",
        "platforms": [{ "name": "iOS", "introducedAt": "13.0" }, { "name": "watchOS", "introducedAt": "6.0", "deprecatedAt": "10.0" }]
      }
    }
    """#.utf8)

    /// Deprecated everywhere, explained only by the platforms' message.
    static let messageOnlyDeprecatedPage = Data(#"""
    {
      "identifier": { "url": "doc://com.example.TestKit/documentation/TestKit/Legacy" },
      "kind": "symbol",
      "metadata": {
        "title": "Legacy", "role": "symbol", "symbolKind": "func",
        "platforms": [{ "name": "iOS", "deprecatedAt": "17.0", "message": "use modern() instead" }]
      }
    }
    """#.utf8)

    static let rootPage = Data(#"""
    {
      "identifier": { "url": "doc://com.example.TestKit/documentation/Root" },
      "kind": "article",
      "metadata": { "title": "Test Book", "role": "collection" },
      "abstract": [{ "type": "text", "text": "A fixture book." }]
    }
    """#.utf8)

    static let technologies = Data(#"""
    {
      "sections": [{ "kind": "technologies", "groups": [
        { "name": "App Frameworks", "technologies": [
          { "title": "TestKit", "tags": ["UI"], "destination": { "identifier": "doc://com.example/documentation/TestKit", "type": "reference" } },
          { "title": "TestKit", "destination": { "identifier": "doc://com.example/documentation/TestKit" } }
        ] },
        { "name": "Empty Group", "technologies": [] }
      ] }],
      "references": {
        "doc://com.example/documentation/TestKit": {
          "type": "topic", "title": "TestKit", "kind": "symbol", "role": "collection",
          "identifier": "doc://com.example/documentation/TestKit", "url": "/documentation/testkit",
          "abstract": [{ "type": "text", "text": "Fixture framework." }]
        }
      }
    }
    """#.utf8)

    static let frameworkPage = Data(#"""
    {
      "identifier": { "url": "doc://com.example.TestKit/documentation/TestKit" },
      "kind": "symbol",
      "metadata": { "title": "TestKit", "role": "collection", "symbolKind": "module", "modules": [{ "name": "TestKit" }] },
      "abstract": [{ "type": "text", "text": "A fixture framework." }]
    }
    """#.utf8)

    static let frameworkIndex = Data(#"""
    { "interfaceLanguages": { "swift": [
      { "title": "TestKit", "path": "/documentation/testkit", "type": "module", "children": [
        { "title": "Essentials", "type": "groupMarker" },
        { "title": "MainWidget", "path": "/documentation/testkit/mainwidget", "type": "class", "children": [
          { "title": "static let shared: MainWidget", "path": "/documentation/testkit/mainwidget/shared", "type": "property" }
        ] },
        { "title": "OldWidget", "path": "/documentation/testkit/oldwidget", "type": "class", "deprecated": true },
        { "title": "WidgetStyle", "path": "/documentation/testkit/widgetstyle", "type": "protocol", "children": [
          { "title": "View Implementations", "path": "/documentation/testkit/widgetstyle/view-implementations", "type": "collection", "children": [
            { "title": "func render()", "path": "/documentation/testkit/widgetstyle/render()", "type": "method" }
          ] }
        ] }
      ] }
    ] } }
    """#.utf8)

    static let navigatorIndex = Data(#"""
    { "interfaceLanguages": { "swift": [
      { "title": "Test Book", "path": "/documentation/root", "type": "module", "children": [
        { "title": "Basics", "type": "groupMarker" },
        { "title": "The Basics", "path": "/documentation/root/thebasics", "type": "article" }
      ] }
    ] } }
    """#.utf8)
}
