import Foundation

struct PipelineBuilder {
    func build(configuration: ProcessingConfiguration, exportDirectory: URL?, folderStructureRoot: URL? = nil) -> ProcessingPipeline {
        var pipeline = ProcessingPipeline()
        pipeline.removeMetadata = configuration.removeMetadata
        pipeline.exportDirectory = exportDirectory
        pipeline.folderStructureRoot = folderStructureRoot
        pipeline.finalFormat = configuration.selectedFormat
        pipeline.compressionPercent = configuration.compressionPercent

        if RestrictedFormatSizing.isRestricted(configuration.selectedFormat) {
            if let format = configuration.selectedFormat {
                pipeline.add(ConstrainSizeOperation(
                    targetFormat: format,
                    resize: configuration.resizeSpecification
                ))
            }
        } else {
            if let resizeOperation = EffectiveImageSizing.resizeOperation(for: configuration.resizeSpecification) {
                pipeline.add(resizeOperation)
            }
        }

        // Compression handled at final export via pipeline.compressionPercent

        // Flip
        if configuration.flipV { pipeline.add(FlipVerticalOperation()) }

        // Remove background
        if configuration.removeBackground { pipeline.add(RemoveBackgroundOperation()) }

        return pipeline
    }
}


