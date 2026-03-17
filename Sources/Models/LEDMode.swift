import Foundation

enum LEDMode: String, Codable, Sendable, CaseIterable {
    case `static` = "static"
    case flashing = "flashing"
    case pulsing = "pulsing"

    /// MIDI channel for this LED mode (0-indexed)
    var midiChannel: UInt8 {
        switch self {
        case .static: 0
        case .flashing: 1
        case .pulsing: 2
        }
    }

    var displayName: String {
        switch self {
        case .static: "Static"
        case .flashing: "Flashing"
        case .pulsing: "Pulsing"
        }
    }
}
