import Foundation

struct ExportRunner {
    let pipeline: ProcessingPipeline
    let configuration: ProcessingConfiguration
    let cacheSnapshot: [UUID: ProcessedImageData]
    let maxConcurrent: Int

    func run(
        targets: [ImageAsset],
        initialImages: [ImageAsset],
        didFinishAsset: @escaping @MainActor () -> Void
    ) async -> [ImageAsset] {
        guard !targets.isEmpty else {
            return initialImages
        }

        var updatedImages = initialImages
        await withTaskGroup(of: (ImageAsset, ImageAsset)?.self) { group in
            var iterator = targets.makeIterator()
            let limit = min(max(1, maxConcurrent), targets.count)

            func addNextTask(
                from iterator: inout IndexingIterator<[ImageAsset]>,
                to group: inout TaskGroup<(ImageAsset, ImageAsset)?>
            ) {
                guard let asset = iterator.next() else { return }
                group.addTask(priority: .utility) {
                    do {
                        let cached = cacheSnapshot[asset.id]
                        let preEncoded = (cached?.configuration == configuration)
                            ? cached.map { (data: $0.data, uti: $0.uti) }
                            : nil
                        let updated = try pipeline.run(on: asset, preEncoded: preEncoded)
                        return (asset, updated)
                    } catch {
                        AppLogger.export.error("Pipeline run failed for \(asset.originalURL.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
                        return nil
                    }
                }
            }

            for _ in 0..<limit {
                addNextTask(from: &iterator, to: &group)
            }

            while let result = await group.next() {
                if let (original, updated) = result,
                   let index = updatedImages.firstIndex(of: original) {
                    updatedImages[index] = updated
                }

                await didFinishAsset()
                addNextTask(from: &iterator, to: &group)
                await Task.yield()
            }
        }

        return updatedImages
    }
}
