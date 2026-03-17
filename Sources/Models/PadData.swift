import Foundation

struct PadData: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: UInt8 { note }

    let note: UInt8
    var colorValue: PadColor
    var ledMode: LEDMode

    enum CodingKeys: String, CodingKey {
        case note
        case colorType = "color_type"
        case colorValue = "color_value"
        case ledMode = "led_mode"
    }

    init(note: UInt8, colorValue: PadColor = .off, ledMode: LEDMode = .static) {
        self.note = note
        self.colorValue = colorValue
        self.ledMode = ledMode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        note = try container.decode(UInt8.self, forKey: .note)
        ledMode = try container.decode(LEDMode.self, forKey: .ledMode)
        // Decode PadColor from flattened keys
        colorValue = try PadColor(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(note, forKey: .note)
        try container.encode(ledMode, forKey: .ledMode)
        // Encode PadColor as flattened keys
        try colorValue.encode(to: encoder)
    }
}
