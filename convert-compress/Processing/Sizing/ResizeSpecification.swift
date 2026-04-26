import Foundation

struct ResizeSpecification: Equatable {
    let mode: ResizeMode
    let width: Int?
    let height: Int?
    let longEdge: Int?

    init(mode: ResizeMode, width: Int?, height: Int?, longEdge: Int?) {
        self.mode = mode
        self.width = width
        self.height = height
        self.longEdge = longEdge
    }

    init(mode: ResizeMode, widthText: String, heightText: String, longEdgeText: String) {
        self.init(
            mode: mode,
            width: Int(widthText),
            height: Int(heightText),
            longEdge: Int(longEdgeText)
        )
    }

    var input: ResizeInput {
        if let longEdge {
            return .longEdge(longEdge)
        }
        return .pixels(width: width, height: height)
    }

    var hasInput: Bool {
        width != nil || height != nil || longEdge != nil
    }

    var cropSize: CGSize? {
        guard mode == .crop, let width, let height else {
            return nil
        }
        return CGSize(width: width, height: height)
    }
}
