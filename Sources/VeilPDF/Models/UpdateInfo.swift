import Foundation

struct UpdateInfo: Equatable {
    let currentVersion: String
    let latestVersion: String
    let releaseURL: URL
    let assetURL: URL?
    let releaseNotes: String

    var isUpdateAvailable: Bool {
        VersionComparator.compare(latestVersion, currentVersion) == .orderedDescending
    }
}

enum VersionComparator {
    static func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let lhsParts = normalizedParts(lhs)
        let rhsParts = normalizedParts(rhs)
        let count = max(lhsParts.count, rhsParts.count)

        for index in 0..<count {
            let lhsValue = index < lhsParts.count ? lhsParts[index] : 0
            let rhsValue = index < rhsParts.count ? rhsParts[index] : 0
            if lhsValue < rhsValue {
                return .orderedAscending
            }
            if lhsValue > rhsValue {
                return .orderedDescending
            }
        }
        return .orderedSame
    }

    private static func normalizedParts(_ version: String) -> [Int] {
        version
            .trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
            .split(separator: ".")
            .map { part in
                let digits = part.prefix { $0.isNumber }
                return Int(digits) ?? 0
            }
    }
}
