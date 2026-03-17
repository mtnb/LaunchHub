import Foundation

enum PadGrid {
    /// Convert grid position to MIDI note number
    /// row: 1-8 (bottom to top), col: 1-8 (left to right)
    static func noteNumber(row: Int, col: Int) -> UInt8 {
        UInt8(row * 10 + col)
    }

    /// Convert MIDI note number to grid position (row, col)
    /// Returns nil if not a valid grid note
    static func position(note: UInt8) -> (row: Int, col: Int)? {
        let row = Int(note) / 10
        let col = Int(note) % 10
        guard row >= 1, row <= 8, col >= 1, col <= 8 else { return nil }
        return (row, col)
    }

    /// 8x8 grid note numbers, indexed [row][col] with row 0 = bottom (row 1 in MIDI)
    static let gridNotes: [[UInt8]] = {
        (1...8).map { row in
            (1...8).map { col in
                noteNumber(row: row, col: col)
            }
        }
    }()

    /// Side button note numbers (right side: x9), bottom to top
    static let sideButtonNotes: [UInt8] = [19, 29, 39, 49, 59, 69, 79, 89]

    /// Top button CC numbers (104-111)
    static let topButtonCCs: [UInt8] = Array(104...111)

    /// All valid grid note numbers
    static let allGridNotes: Set<UInt8> = {
        var notes = Set<UInt8>()
        for row in gridNotes {
            for note in row {
                notes.insert(note)
            }
        }
        return notes
    }()
}
