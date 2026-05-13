import Foundation

struct PreparedIngestion {
    let assets: [ImageAsset]
    let sourceDirectory: URL?
}

/// Plans an already-discovered URL batch for ingestion.
///
/// `IngestionCoordinator` adapts external inputs (pasteboard, item providers,
/// open panels) into URLs. This module owns the app policy for those URLs:
/// readability, standardization, duplicate removal, and asset creation.
struct IngestionPlanner {
    func prepare(urls: [URL], existingURLs: Set<URL>) -> PreparedIngestion? {
        let readableURLs = readableImageURLs(from: urls)
        guard !readableURLs.isEmpty else {
            AppLogger.ingestion.debug("Ingest skip: no readable URLs from \(urls.count, privacy: .public) inputs")
            return nil
        }

        AppLogger.ingestion.debug("Ingest start: \(readableURLs.count, privacy: .public) readable URLs")

        let newURLs = newImageURLs(from: readableURLs, existingURLs: existingURLs)
        guard !newURLs.isEmpty else {
            AppLogger.ingestion.debug("Ingest skip: all URLs already present")
            return nil
        }

        AppLogger.ingestion.debug("Ingest new URLs: \(newURLs.count, privacy: .public)")

        return PreparedIngestion(
            assets: newURLs.map { ImageAsset(url: $0) },
            sourceDirectory: newURLs.first?.deletingLastPathComponent()
        )
    }

    private func readableImageURLs(from urls: [URL]) -> [URL] {
        urls
            .filter { ImageIOCapabilities.shared.isReadableURL($0) }
            .map { $0.standardizedFileURL }
    }

    private func newImageURLs(from urls: [URL], existingURLs: Set<URL>) -> [URL] {
        var seen = existingURLs
        var result: [URL] = []
        for url in urls where !seen.contains(url) {
            seen.insert(url)
            result.append(url)
        }
        return result
    }
}
