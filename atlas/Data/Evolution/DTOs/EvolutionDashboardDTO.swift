import Foundation

nonisolated struct EvolutionDashboardDTO: Decodable, Sendable {
    nonisolated struct Proposal: Decodable, Sendable {
        nonisolated struct Status: Decodable, Sendable {
            let state: String?
            let version: String?
        }

        nonisolated struct FeatureFlag: Decodable, Sendable {
            let flag: String?
        }

        let id: String?
        /// File name in `proposals/`, e.g. `0461-async-function-isolation.md` (case-sensitive).
        let link: String?
        let title: String?
        let summary: String?
        let status: Status?
        /// Git blob SHA of the proposal file: changes exactly when the file changes.
        let sha: String?
        let upcomingFeatureFlag: FeatureFlag?
    }

    let proposals: [Proposal]?
}
