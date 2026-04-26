import Foundation

enum EffectiveImageSizing {
    static func targetPixelSize(
        originalSize: CGSize?,
        isVector: Bool,
        resize: ResizeSpecification,
        selectedFormat: ImageFormat?
    ) -> CGSize? {
        guard let baseSize = originalSize else {
            return CGSize(width: 0, height: 0)
        }

        let effectiveBase = (isVector && resize.hasInput)
            ? VectorImageSupport.generousSize(for: baseSize)
            : baseSize
        var size = ResizeMath.targetSize(for: effectiveBase, input: resize.input, noUpscale: true)

        if let cropSize = resize.cropSize {
            size = cropSize
        }

        if let selectedFormat,
           ImageIOCapabilities.shared.sizeRestrictions(forUTType: selectedFormat.utType) != nil {
            let side = min(size.width, size.height)
            size = CGSize(width: side, height: side)
        }

        return size
    }

    static func resizeOperation(for resize: ResizeSpecification) -> ImageOperation? {
        if let cropSize = resize.cropSize {
            return CropOperation(
                targetWidth: Int(cropSize.width),
                targetHeight: Int(cropSize.height)
            )
        }

        guard resize.hasInput else {
            return nil
        }

        return ResizeOperation(input: resize.input)
    }
}
