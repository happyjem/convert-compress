import CoreImage
import Foundation

/// Ensures the image matches the size restrictions of a target format by resizing when necessary.
struct ConstrainSizeOperation: ImageOperation {
    let targetFormat: ImageFormat

    func transformed(_ input: CIImage) throws -> CIImage {
        let capabilities = ImageIOCapabilities.shared
        let current = input.extent.size

        guard capabilities.sizeRestrictions(forUTType: targetFormat.utType) != nil,
              !capabilities.isValidPixelSize(current, for: targetFormat.utType),
              let side = capabilities.suggestedSquareSide(for: targetFormat.utType, source: current) else {
            return input
        }

        let target = CGSize(width: side, height: side)
        let scaleX = target.width / current.width
        let scaleY = target.height / current.height
        return try lanczosScale(
            input,
            scale: Float(min(scaleX, scaleY)),
            aspectRatio: Float(scaleX / scaleY),
            targetSize: target
        )
    }
}
