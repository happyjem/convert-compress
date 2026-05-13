import Foundation

enum RestrictedFormatSizing {
    static func allowedSquareSizes(for format: ImageFormat?) -> [Int]? {
        guard let format,
              let sizes = ImageIOCapabilities.shared.sizeRestrictions(forUTType: format.utType) else {
            return nil
        }
        return sizes.sorted()
    }

    static func isRestricted(_ format: ImageFormat?) -> Bool {
        guard let format else {
            return false
        }
        return ImageIOCapabilities.shared.sizeRestrictions(forUTType: format.utType) != nil
    }

    static func targetSquareSide(
        sourceSize: CGSize,
        resize: ResizeSpecification,
        format: ImageFormat?
    ) -> Int? {
        guard let allowedSizes = allowedSquareSizes(for: format),
              !allowedSizes.isEmpty else {
            return nil
        }

        let basis = requestedSquareBasis(from: resize) ?? min(sourceSize.width, sourceSize.height)
        return nearestAllowedSide(to: basis, allowedSizes: allowedSizes)
    }

    private static func requestedSquareBasis(from resize: ResizeSpecification) -> CGFloat? {
        if let cropSize = resize.cropSize {
            return min(cropSize.width, cropSize.height)
        }

        if let longEdge = resize.longEdge {
            return CGFloat(longEdge)
        }

        switch (resize.width, resize.height) {
        case let (width?, height?):
            return CGFloat(min(width, height))
        case let (width?, nil):
            return CGFloat(width)
        case let (nil, height?):
            return CGFloat(height)
        case (nil, nil):
            return nil
        }
    }

    private static func nearestAllowedSide(to basis: CGFloat, allowedSizes: [Int]) -> Int {
        let roundedBasis = Int(basis.rounded())
        return allowedSizes.min { lhs, rhs in
            let lhsDistance = abs(lhs - roundedBasis)
            let rhsDistance = abs(rhs - roundedBasis)
            if lhsDistance == rhsDistance {
                return lhs > rhs
            }
            return lhsDistance < rhsDistance
        } ?? roundedBasis
    }
}
