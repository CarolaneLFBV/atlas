import Foundation

nonisolated enum CatalogueMerging {
    static func merged(_ categories: [DocumentationCatalogue.Category]) -> [DocumentationCatalogue.Category] {
        var order: [String] = []
        var frameworksByName: [String: [DocumentationFramework]] = [:]
        var seen = Set<DocumentationID>()
        for category in categories {
            if frameworksByName[category.name] == nil { order.append(category.name) }
            let unique = category.frameworks.filter { seen.insert($0.id).inserted }
            frameworksByName[category.name, default: []] += unique
        }
        return order.compactMap { name in
            guard let frameworks = frameworksByName[name], !frameworks.isEmpty else { return nil }
            return DocumentationCatalogue.Category(name: name, frameworks: frameworks)
        }
    }

    /// The least current of several freshness values.
    static func combined(_ values: [Freshness]) -> Freshness {
        var oldestStale: Date?
        var oldestCached: Date?
        for value in values {
            switch value {
            case .fresh: break
            case .cached(let date): oldestCached = min(oldestCached ?? date, date)
            case .stale(let date): oldestStale = min(oldestStale ?? date, date)
            }
        }
        if let oldestStale { return .stale(fetchedAt: oldestStale) }
        if let oldestCached { return .cached(fetchedAt: oldestCached) }
        return .fresh
    }
}
