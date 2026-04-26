import Foundation

enum PreviewEstimator {
    static func estimate(for asset: ImageAsset,
                         configuration: ProcessingConfiguration) -> PreviewInfo {
        let targetSize = EffectiveImageSizing.targetPixelSize(
            originalSize: asset.originalPixelSize,
            isVector: VectorImageSupport.isVectorImage(asset.originalURL),
            resize: configuration.resizeSpecification,
            selectedFormat: configuration.selectedFormat
        )
        return PreviewInfo(targetPixelSize: targetSize)
    }
}

