import Foundation

enum ExportFormat: String, CaseIterable, Sendable {
    case launchhub
    case json
    case midi

    var displayName: String {
        switch self {
        case .launchhub: ".launchhub (Project)"
        case .json: ".json (Data Export)"
        case .midi: ".mid (Standard MIDI File)"
        }
    }

    var fileExtension: String {
        switch self {
        case .launchhub: "launchhub"
        case .json: "json"
        case .midi: "mid"
        }
    }

    var mimeType: String {
        switch self {
        case .launchhub: "application/octet-stream"
        case .json: "application/json"
        case .midi: "audio/midi"
        }
    }
}
