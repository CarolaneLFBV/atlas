import Foundation

/// Test data only.
enum EvolutionFixtures {
    static let dashboard = Data(#"""
    { "commit": "abc", "proposals": [
      { "id": "SE-0461", "link": "0461-async-function-isolation.md", "sha": "sha-0461-v1",
        "title": "Run nonisolated `async` functions on the caller's actor by default",
        "summary": "Changes the default isolation of async functions.",
        "status": { "state": "implemented", "version": "6.2" },
        "upcomingFeatureFlag": { "flag": "NonisolatedNonsendingByDefault" } },
      { "id": "SE-0467", "link": "0467-MutableSpan.md", "sha": "sha-0467",
        "title": "MutableSpan", "status": { "state": "implemented", "version": "6.10" } },
      { "id": "SE-0999", "link": "0999-review.md", "sha": "sha-0999",
        "title": "In review", "status": { "state": "activeReview" } },
      { "id": "SE-0001", "link": "0001-old.md", "title": "Old", "status": { "state": "implemented", "version": "6.9" } }
    ] }
    """#.utf8)

    static let proposal = """
    # Run nonisolated async functions on the caller's actor by default

    * Proposal: [SE-0461](0461-async-function-isolation.md)
    * Previous Proposal: [SE-0338](0338-clarify-execution-non-actor-async.md)

    ## Table of Contents

    - [Motivation](#motivation)

    ## Detailed design

    ### `@concurrent` functions

    Use `@concurrent` to *always* switch off the actor. See the [forums](https://forums.swift.org).

    ```swift
    @concurrent func alwaysSwitch() async {}
    ```

    > [!NOTE]
    > Callouts are rendered as asides.

    | Spelling | Meaning |
    |---|---|
    | `@concurrent` | switches |

    1. First
    2. Second
    """
}
