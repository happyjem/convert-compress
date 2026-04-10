import Foundation

struct TrueSizeEstimator {
    static func estimate(
        assets: [ImageAsset],
        configuration: ProcessingConfiguration
    ) async -> [UUID: ProcessedImageData] {
        guard !assets.isEmpty else { return [:] }

        let pipeline = PipelineBuilder().build(configuration: configuration, exportDirectory: nil)
        let maxConcurrent = 4
        var results: [UUID: ProcessedImageData] = [:]
        var index = 0

        while index < assets.count {
            guard !Task.isCancelled else { break }

            let end = min(index + maxConcurrent, assets.count)
            let slice = Array(assets[index..<end])
            await withTaskGroup(of: (UUID, ProcessedImageData)?.self) { group in
                for asset in slice {
                    group.addTask(priority: .utility) {
                        guard !Task.isCancelled else { return nil }
                        return processOne(asset: asset, pipeline: pipeline, configuration: configuration)
                    }
                }
                for await item in group {
                    if let (id, result) = item { results[id] = result }
                }
            }
            index = end
            await Task.yield()
        }

        return results
    }

    private static func processOne(
        asset: ImageAsset,
        pipeline: ProcessingPipeline,
        configuration: ProcessingConfiguration
    ) -> (UUID, ProcessedImageData)? {
        do {
            let encoded = try pipeline.renderEncodedData(on: asset)
            let result = ProcessedImageData(
                data: encoded.data,
                uti: encoded.uti,
                configuration: configuration
            )
            return (asset.id, result)
        } catch {
            return nil
        }
    }
}
