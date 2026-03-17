import Foundation

struct CCButtonData: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: UInt8 { cc }

    let cc: UInt8
    var colorValue: PadColor

    enum CodingKeys: String, CodingKey {
        case cc
        case colorType = "color_type"
        case colorValue = "color_value"
    }

    init(cc: UInt8, colorValue: PadColor = .off) {
        self.cc = cc
        self.colorValue = colorValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cc = try container.decode(UInt8.self, forKey: .cc)
        colorValue = try PadColor(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cc, forKey: .cc)
        try colorValue.encode(to: encoder)
    }
}
