import Foundation

struct PipelineBuilder {
    func build(configuration: ProcessingConfiguration, exportDirectory: URL?, folderStructureRoot: URL? = nil) -> ProcessingPipeline {
        var pipeline = ProcessingPipeline()
        pipeline.removeMetadata = configuration.removeMetadata
        pipeline.exportDirectory = exportDirectory
        pipeline.folderStructureRoot = folderStructureRoot
        pipeline.finalFormat = configuration.selectedFormat
        pipeline.compressionPercent = configuration.compressionPercent

        if let resizeOperation = EffectiveImageSizing.resizeOperation(for: configuration.resizeSpecification) {
            pipeline.add(resizeOperation)
        }

        // Enforce format-specific size constraints before conversion
        if let format = configuration.selectedFormat {
            let caps = ImageIOCapabilities.shared
            if caps.sizeRestrictions(forUTType: format.utType) != nil {
                pipeline.add(ConstrainSizeOperation(targetFormat: format))
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


