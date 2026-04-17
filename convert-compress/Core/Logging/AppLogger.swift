import Foundation
import OSLog

/// Central logger namespace. Prefer these loggers over `print` so diagnostics
/// flow to the unified logging system and can be filtered per-subsystem.
enum AppLogger {
    private static let subsystem = AppConstants.bundleIdentifier

    static let app        = Logger(subsystem: subsystem, category: "app")
    static let ingestion  = Logger(subsystem: subsystem, category: "ingestion")
    static let export     = Logger(subsystem: subsystem, category: "export")
    static let processing = Logger(subsystem: subsystem, category: "processing")
    static let sandbox    = Logger(subsystem: subsystem, category: "sandbox")
    static let purchase   = Logger(subsystem: subsystem, category: "purchase")
    static let presets    = Logger(subsystem: subsystem, category: "presets")
    static let rating     = Logger(subsystem: subsystem, category: "rating")
    static let usage      = Logger(subsystem: subsystem, category: "usage")
}
