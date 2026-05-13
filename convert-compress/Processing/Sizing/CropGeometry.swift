import Foundation

enum CropGeometry {
    static func normalizedCenterCropRegion(originalSize: CGSize, targetSize: CGSize) -> CGRect? {
        guard originalSize.width > 0,
              originalSize.height > 0,
              targetSize.width > 0,
              targetSize.height > 0 else {
            return nil
        }

        let scale = max(targetSize.width / originalSize.width, targetSize.height / originalSize.height)
        let scaledSize = CGSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )

        let cropOrigin = CGPoint(
            x: (scaledSize.width - targetSize.width) / 2,
            y: (scaledSize.height - targetSize.height) / 2
        )

        return CGRect(
            x: cropOrigin.x / scale / originalSize.width,
            y: cropOrigin.y / scale / originalSize.height,
            width: targetSize.width / scale / originalSize.width,
            height: targetSize.height / scale / originalSize.height
        )
    }
}
