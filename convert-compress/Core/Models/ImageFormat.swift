import Foundation
import UniformTypeIdentifiers

struct ImageFormat: Identifiable, Hashable, Equatable, Codable {
    let utType: UTType

    var id: String { utType.identifier }

    var displayName: String {
        let ext = preferredFilenameExtension
        if !ext.isEmpty && ext != "img" { return ext.uppercased() }
        let id = utType.identifier
        if let last = id.split(separator: ".").last, last.count <= 8 {
            return last.uppercased()
        }
        return (utType.localizedDescription ?? id).uppercased()
    }

    var preferredFilenameExtension: String {
        ImageIOCapabilities.shared.preferredFilenameExtension(for: utType)
    }

    var fullName: String {
        utType.localizedDescription ?? utType.identifier
    }

    init(utType: UTType) {
        self.utType = utType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        guard let format = ImageIOCapabilities.shared.format(forIdentifier: identifier) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown image format: \(identifier)"
            )
        }
        self.utType = format.utType
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(utType.identifier)
    }
}

