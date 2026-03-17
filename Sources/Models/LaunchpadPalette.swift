import SwiftUI

/// Launchpad 128-color palette lookup table
/// Maps velocity values (0-127) to approximate SwiftUI Colors
enum LaunchpadPalette {
    /// RGB values for each of the 128 palette entries (approximate)
    private static let colors: [(r: UInt8, g: UInt8, b: UInt8)] = [
        // 0-7
        (0, 0, 0),       // 0: Off
        (30, 30, 30),    // 1: Dark Grey
        (127, 127, 127), // 2: Grey
        (255, 255, 255), // 3: White
        (255, 76, 76),   // 4: Light Red
        (255, 0, 0),     // 5: Red
        (89, 0, 0),      // 6: Dark Red
        (25, 0, 0),      // 7: Darker Red
        // 8-15
        (255, 189, 108), // 8: Light Orange
        (255, 84, 0),    // 9: Orange
        (89, 29, 0),     // 10: Dark Orange
        (39, 13, 0),     // 11: Darker Orange
        (255, 255, 76),  // 12: Light Yellow
        (255, 255, 0),   // 13: Yellow
        (89, 89, 0),     // 14: Dark Yellow
        (25, 25, 0),     // 15: Darker Yellow
        // 16-23
        (131, 255, 76),  // 16: Light Lime
        (84, 255, 0),    // 17: Lime
        (29, 89, 0),     // 18: Dark Lime
        (13, 39, 0),     // 19: Darker Lime
        (76, 255, 76),   // 20: Light Green
        (0, 255, 0),     // 21: Green
        (0, 89, 0),      // 22: Dark Green
        (0, 25, 0),      // 23: Darker Green
        // 24-31
        (76, 255, 94),   // 24: Light Green 2
        (0, 255, 25),    // 25: Green 2
        (0, 89, 13),     // 26: Dark Green 2
        (0, 39, 0),      // 27: Darker Green 2
        (76, 255, 131),  // 28: Light Teal
        (0, 255, 50),    // 29: Teal
        (0, 89, 25),     // 30: Dark Teal
        (0, 39, 13),     // 31: Darker Teal
        // 32-39
        (76, 255, 176),  // 32: Light Cyan Green
        (0, 255, 101),   // 33: Cyan Green
        (0, 89, 38),     // 34: Dark Cyan Green
        (0, 39, 16),     // 35: Darker Cyan Green
        (76, 255, 255),  // 36: Light Cyan
        (0, 255, 255),   // 37: Cyan
        (0, 89, 89),     // 38: Dark Cyan
        (0, 25, 25),     // 39: Darker Cyan
        // 40-47
        (76, 131, 255),  // 40: Light Blue
        (0, 84, 255),    // 41: Blue
        (0, 29, 89),     // 42: Dark Blue
        (0, 13, 39),     // 43: Darker Blue
        (76, 76, 255),   // 44: Light Blue 2
        (0, 0, 255),     // 45: Blue
        (0, 0, 89),      // 46: Dark Blue 2
        (0, 0, 25),      // 47: Darker Blue 2
        // 48-55
        (131, 76, 255),  // 48: Light Purple
        (84, 0, 255),    // 49: Purple
        (29, 0, 89),     // 50: Dark Purple
        (20, 0, 39),     // 51: Darker Purple
        (255, 76, 255),  // 52: Light Magenta
        (255, 0, 255),   // 53: Magenta
        (89, 0, 89),     // 54: Dark Magenta
        (25, 0, 25),     // 55: Darker Magenta
        // 56-63
        (255, 76, 131),  // 56: Light Pink
        (255, 0, 84),    // 57: Pink
        (89, 0, 29),     // 58: Dark Pink
        (39, 0, 13),     // 59: Darker Pink
        (255, 21, 0),    // 60: Bright Red
        (153, 53, 0),    // 61: Med Orange
        (121, 81, 0),    // 62: Light Brown
        (67, 100, 0),    // 63: Dark Lime
        // 64-71
        (3, 57, 0),      // 64: Forest Green
        (0, 87, 53),     // 65: Dark Teal
        (0, 84, 127),    // 66: Dark Sky Blue
        (0, 0, 255),     // 67: Blue
        (0, 68, 76),     // 68: Slate Blue
        (37, 0, 204),    // 69: Indigo
        (127, 127, 127), // 70: Grey
        (32, 32, 32),    // 71: Dark Grey 2
        // 72-79
        (255, 0, 0),     // 72: Red
        (189, 255, 45),  // 73: Yellow Green
        (175, 237, 6),   // 74: Chartreuse
        (100, 255, 0),   // 75: Bright Green
        (16, 139, 0),    // 76: Green
        (0, 255, 140),   // 77: Emerald
        (0, 140, 255),   // 78: Sky Blue
        (0, 44, 255),    // 79: Royal Blue
        // 80-87
        (132, 0, 255),   // 80: Violet
        (130, 0, 196),   // 81: Purple
        (176, 0, 255),   // 82: Bright Purple
        (255, 0, 89),    // 83: Hot Pink
        (255, 110, 0),   // 84: Orange
        (201, 255, 0),   // 85: Yellow Green
        (0, 255, 0),     // 86: Green
        (0, 255, 152),   // 87: Aquamarine
        // 88-95
        (0, 169, 255),   // 88: Light Blue
        (0, 42, 255),    // 89: Blue
        (63, 0, 255),    // 90: Indigo
        (122, 0, 255),   // 91: Violet
        (178, 0, 255),   // 92: Purple
        (255, 0, 175),   // 93: Pink
        (255, 84, 0),    // 94: Orange
        (255, 255, 0),   // 95: Yellow
        // 96-103
        (131, 255, 0),   // 96: Lime
        (0, 255, 0),     // 97: Green
        (0, 255, 99),    // 98: Mint
        (0, 186, 255),   // 99: Sky Blue
        (0, 72, 255),    // 100: Blue
        (63, 0, 201),    // 101: Deep Purple
        (127, 0, 255),   // 102: Purple
        (255, 0, 127),   // 103: Pink
        // 104-111
        (255, 18, 0),    // 104: Red Orange
        (255, 140, 0),   // 105: Orange
        (100, 100, 0),   // 106: Olive
        (0, 145, 0),     // 107: Green
        (0, 134, 101),   // 108: Teal
        (0, 0, 145),     // 109: Navy
        (0, 0, 255),     // 110: Blue
        (63, 0, 153),    // 111: Indigo
        // 112-119
        (127, 127, 127), // 112: Grey
        (210, 0, 0),     // 113: Dark Red
        (204, 127, 0),   // 114: Dark Orange
        (165, 168, 0),   // 115: Olive
        (63, 148, 0),    // 116: Dark Green
        (0, 127, 63),    // 117: Dark Teal
        (0, 100, 150),   // 118: Dark Blue
        (63, 0, 127),    // 119: Dark Purple
        // 120-127
        (109, 0, 63),    // 120: Dark Pink
        (255, 0, 0),     // 121: Red
        (178, 86, 0),    // 122: Rust
        (140, 178, 0),   // 123: Yellow Green
        (0, 178, 0),     // 124: Green
        (0, 178, 127),   // 125: Teal
        (0, 76, 178),    // 126: Blue
        (255, 255, 255), // 127: White
    ]

    static func color(for velocity: UInt8) -> Color {
        let index = Int(min(velocity, 127))
        let c = colors[index]
        return Color(
            red: Double(c.r) / 255.0,
            green: Double(c.g) / 255.0,
            blue: Double(c.b) / 255.0
        )
    }

    static let count = 128
}
