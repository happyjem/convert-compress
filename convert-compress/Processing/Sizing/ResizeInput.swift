import Foundation

enum ResizeInput {
    case percent(Double)
    case pixels(width: Int?, height: Int?)
    case longEdge(Int)
}
