import Foundation

enum UpdateServiceError: LocalizedError {
    case invalidResponse
    case missingReleaseURL

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Could not read the latest VeilPDF release from GitHub."
        case .missingReleaseURL:
            "The latest VeilPDF release did not include a release URL."
        }
    }
}

struct UpdateService {
    private let latestReleaseURL = URL(string: "https://api.github.com/repos/jasoncantor/veilpdf/releases/latest")!

    func checkForUpdates(currentVersion: String) async throws -> UpdateInfo {
        var request = URLRequest(url: latestReleaseURL)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("VeilPDF", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw UpdateServiceError.invalidResponse
        }

        let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
        guard let releaseURL = URL(string: release.htmlURL) else {
            throw UpdateServiceError.missingReleaseURL
        }

        return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV")),
            releaseURL: releaseURL,
            assetURL: release.assets.first { $0.name.hasSuffix(".dmg") }.flatMap { URL(string: $0.browserDownloadURL) },
            releaseNotes: release.body
        )
    }
}

private struct GitHubRelease: Decodable {
    let tagName: String
    let htmlURL: String
    let body: String
    let assets: [GitHubReleaseAsset]

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
        case body
        case assets
    }
}

private struct GitHubReleaseAsset: Decodable {
    let name: String
    let browserDownloadURL: String

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadURL = "browser_download_url"
    }
}
