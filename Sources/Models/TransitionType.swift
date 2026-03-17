import Foundation

enum TransitionType: String, Codable, Sendable, CaseIterable {
    case cut
    case fade
    case slide

    var displayName: String {
        switch self {
        case .cut: "Cut"
        case .fade: "Fade"
        case .slide: "Slide"
        }
    }
}
