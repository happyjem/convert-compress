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

        let usesResizePipeline = resize.hasInput || RestrictedFormatSizing.isRestricted(selectedFormat)
        let effectiveBase = (isVector && usesResizePipeline)
            ? VectorImageSupport.generousSize(for: baseSize)
            : baseSize

        if let side = RestrictedFormatSizing.targetSquareSide(
            sourceSize: effectiveBase,
            resize: resize,
            format: selectedFormat
        ) {
            return CGSize(width: side, height: side)
        }

        var size = ResizeMath.targetSize(for: effectiveBase, input: resize.input, noUpscale: true)

        if let cropSize = resize.cropSize {
            size = cropSize
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
