import SwiftUI

enum PadColor: Sendable, Equatable, Hashable {
    case palette(UInt8)
    case rgb(r: UInt8, g: UInt8, b: UInt8)

    /// Convert to a SwiftUI Color for display
    var displayColor: Color {
        switch self {
        case .palette(let value):
            if value == 0 { return .gridOff }
            return LaunchpadPalette.color(for: value)
        case .rgb(let r, let g, let b):
            // Launchpad RGB values are 0-63, scale to 0-1
            return Color(
                red: Double(r) / 63.0,
                green: Double(g) / 63.0,
                blue: Double(b) / 63.0
            )
        }
    }

    static let off = PadColor.palette(0)
}

// MARK: - Custom Codable (file-format.md compliant)
extension PadColor: Codable {
    enum CodingKeys: String, CodingKey {
        case colorType = "color_type"
        case colorValue = "color_value"
    }

    private enum ColorType: String, Codable {
        case palette
        case rgb
    }

    private struct RGBValue: Codable {
        let r: UInt8
        let g: UInt8
        let b: UInt8
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ColorType.self, forKey: .colorType)
        switch type {
        case .palette:
            let value = try container.decode(UInt8.self, forKey: .colorValue)
            self = .palette(value)
        case .rgb:
            let rgb = try container.decode(RGBValue.self, forKey: .colorValue)
            self = .rgb(r: rgb.r, g: rgb.g, b: rgb.b)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .palette(let value):
            try container.encode(ColorType.palette, forKey: .colorType)
            try container.encode(value, forKey: .colorValue)
        case .rgb(let r, let g, let b):
            try container.encode(ColorType.rgb, forKey: .colorType)
            try container.encode(RGBValue(r: r, g: g, b: b), forKey: .colorValue)
        }
    }
}
