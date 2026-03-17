import SwiftUI
import Observation

@Observable
@MainActor
final class ColorPickerViewModel {
    enum Mode: String, CaseIterable {
        case palette = "Palette"
        case rgb = "RGB"
    }

    var mode: Mode = .palette
    var recentColors: [PadColor] = []
    var rgbRed: Double = 0
    var rgbGreen: Double = 0
    var rgbBlue: Double = 0

    private let maxRecentColors = 8

    func addToRecent(_ color: PadColor) {
        recentColors.removeAll { $0 == color }
        recentColors.insert(color, at: 0)
        if recentColors.count > maxRecentColors {
            recentColors.removeLast()
        }
    }

    var currentRGBColor: PadColor {
        .rgb(r: UInt8(rgbRed), g: UInt8(rgbGreen), b: UInt8(rgbBlue))
    }
}
