import Foundation

struct Frame: Codable, Sendable, Equatable, Identifiable {
    var id: Int { index }

    var index: Int
    var durationMs: Int
    var transition: TransitionType
    var pads: [PadData]
    var ccButtons: [CCButtonData]
    var sceneButtons: [PadData]

    enum CodingKeys: String, CodingKey {
        case index
        case durationMs = "duration_ms"
        case transition
        case pads
        case ccButtons = "cc_buttons"
        case sceneButtons = "scene_buttons"
    }

    /// Create a blank frame with default values
    static func blank(index: Int, durationMs: Int = 500) -> Frame {
        Frame(
            index: index,
            durationMs: durationMs,
            transition: .cut,
            pads: [],
            ccButtons: [],
            sceneButtons: []
        )
    }
}
