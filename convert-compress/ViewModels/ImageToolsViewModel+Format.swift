import Foundation

extension ImageToolsViewModel {
    func updateRestrictions(for format: ImageFormat?) {
        allowedSquareSizes = RestrictedFormatSizing.allowedSquareSizes(for: format)
    }

    func onSelectedFormatChanged(_ format: ImageFormat?) {
        updateRestrictions(for: format)
        guard allowedSquareSizes != nil else { return }
        
        // Choose a reference size from first asset (prefer cached value)
        guard let firstImage = images.first else { return }
        let sourceSize = firstImage.originalPixelSize ?? .zero
        
        if let side = RestrictedFormatSizing.targetSquareSide(
            sourceSize: sourceSize,
            resize: currentConfiguration.resizeSpecification,
            format: format
        ) {
            resizeMode = .crop
            resizeWidth = String(side)
            resizeHeight = String(side)
        }
    }
}
