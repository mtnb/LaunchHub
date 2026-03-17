import Foundation

enum BuiltInPresets {
    static let all: [Project] = [
        rainbowWave,
        breathingPulse,
        checkerboardFlash,
        diagonalSweep,
        colorBurst,
        spiralIn,
        randomSparkle,
        warmGlow,
    ]

    // MARK: - Rainbow Wave (8 frames)

    static let rainbowWave: Project = {
        let colors: [UInt8] = [5, 9, 13, 21, 45, 53, 81, 48]
        var frames: [Frame] = []
        for frameIdx in 0..<8 {
            var pads: [PadData] = []
            for row in 0..<8 {
                let colorIdx = (row + frameIdx) % 8
                for col in 1...8 {
                    let note = PadGrid.noteNumber(row: row + 1, col: col)
                    pads.append(PadData(note: note, colorValue: .palette(colors[colorIdx]), ledMode: .static))
                }
            }
            frames.append(Frame(index: frameIdx, durationMs: 250, transition: .cut, pads: pads, ccButtons: [], sceneButtons: []))
        }
        return Project(
            version: "1.0",
            metadata: ProjectMetadata(name: "Rainbow Wave", created: .distantPast, modified: .distantPast, bpm: 120, author: "Built-in"),
            targetDevice: .x,
            frames: frames
        )
    }()

    // MARK: - Breathing Pulse (4 frames)

    static let breathingPulse: Project = {
        var frames: [Frame] = []
        let colors: [UInt8] = [45, 53, 41, 37]
        for frameIdx in 0..<4 {
            var pads: [PadData] = []
            for row in 1...8 {
                for col in 1...8 {
                    let note = PadGrid.noteNumber(row: row, col: col)
                    pads.append(PadData(note: note, colorValue: .palette(colors[frameIdx]), ledMode: .pulsing))
                }
            }
            frames.append(Frame(index: frameIdx, durationMs: 500, transition: .cut, pads: pads, ccButtons: [], sceneButtons: []))
        }
        return Project(
            version: "1.0",
            metadata: ProjectMetadata(name: "Breathing Pulse", created: .distantPast, modified: .distantPast, bpm: 90, author: "Built-in"),
            targetDevice: .x,
            frames: frames
        )
    }()

    // MARK: - Checkerboard Flash (2 frames)

    static let checkerboardFlash: Project = {
        var frames: [Frame] = []
        for frameIdx in 0..<2 {
            var pads: [PadData] = []
            for row in 1...8 {
                for col in 1...8 {
                    let note = PadGrid.noteNumber(row: row, col: col)
                    let isEven = (row + col) % 2 == frameIdx
                    let color: UInt8 = isEven ? 5 : 0
                    if color > 0 {
                        pads.append(PadData(note: note, colorValue: .palette(color), ledMode: .flashing))
                    }
                }
            }
            frames.append(Frame(index: frameIdx, durationMs: 350, transition: .cut, pads: pads, ccButtons: [], sceneButtons: []))
        }
        return Project(
            version: "1.0",
            metadata: ProjectMetadata(name: "Checkerboard Flash", created: .distantPast, modified: .distantPast, bpm: 140, author: "Built-in"),
            targetDevice: .x,
            frames: frames
        )
    }()

    // MARK: - Diagonal Sweep (8 frames)

    static let diagonalSweep: Project = {
        var frames: [Frame] = []
        for frameIdx in 0..<8 {
            var pads: [PadData] = []
            for row in 1...8 {
                for col in 1...8 {
                    let diag = row + col - 2
                    if diag >= frameIdx && diag < frameIdx + 3 {
                        let note = PadGrid.noteNumber(row: row, col: col)
                        pads.append(PadData(note: note, colorValue: .palette(13), ledMode: .static))
                    }
                }
            }
            frames.append(Frame(index: frameIdx, durationMs: 200, transition: .cut, pads: pads, ccButtons: [], sceneButtons: []))
        }
        return Project(
            version: "1.0",
            metadata: ProjectMetadata(name: "Diagonal Sweep", created: .distantPast, modified: .distantPast, bpm: 150, author: "Built-in"),
            targetDevice: .x,
            frames: frames
        )
    }()

    // MARK: - Color Burst (6 frames)

    static let colorBurst: Project = {
        var frames: [Frame] = []
        let centerR = 4, centerC = 4
        for frameIdx in 0..<6 {
            var pads: [PadData] = []
            for row in 1...8 {
                for col in 1...8 {
                    let dist = max(abs(row - centerR), abs(col - centerC))
                    if dist <= frameIdx {
                        let note = PadGrid.noteNumber(row: row, col: col)
                        let colorIdx: UInt8 = UInt8(5 + (dist * 4))
                        pads.append(PadData(note: note, colorValue: .palette(colorIdx), ledMode: .static))
                    }
                }
            }
            frames.append(Frame(index: frameIdx, durationMs: 300, transition: .cut, pads: pads, ccButtons: [], sceneButtons: []))
        }
        return Project(
            version: "1.0",
            metadata: ProjectMetadata(name: "Color Burst", created: .distantPast, modified: .distantPast, bpm: 100, author: "Built-in"),
            targetDevice: .x,
            frames: frames
        )
    }()

    // MARK: - Spiral In (8 frames)

    static let spiralIn: Project = {
        // Simplified spiral: concentric rings
        var frames: [Frame] = []
        for frameIdx in 0..<4 {
            var pads: [PadData] = []
            let ring = frameIdx
            for row in 1...8 {
                for col in 1...8 {
                    let minDist = min(min(row - 1, 8 - row), min(col - 1, 8 - col))
                    if minDist == ring {
                        let note = PadGrid.noteNumber(row: row, col: col)
                        pads.append(PadData(note: note, colorValue: .palette(21), ledMode: .pulsing))
                    }
                }
            }
            frames.append(Frame(index: frameIdx, durationMs: 400, transition: .cut, pads: pads, ccButtons: [], sceneButtons: []))
        }
        return Project(
            version: "1.0",
            metadata: ProjectMetadata(name: "Spiral In", created: .distantPast, modified: .distantPast, bpm: 110, author: "Built-in"),
            targetDevice: .x,
            frames: frames
        )
    }()

    // MARK: - Random Sparkle (4 frames with seeded positions)

    static let randomSparkle: Project = {
        var frames: [Frame] = []
        let sparkleNotes: [[UInt8]] = [
            [11, 23, 35, 47, 58, 66, 74, 82],
            [18, 22, 36, 44, 51, 63, 77, 85],
            [14, 26, 38, 42, 55, 67, 71, 88],
            [12, 28, 34, 46, 53, 61, 78, 84],
        ]
        for (frameIdx, notes) in sparkleNotes.enumerated() {
            let pads = notes.map { note in
                PadData(note: note, colorValue: .palette(127), ledMode: .flashing)
            }
            frames.append(Frame(index: frameIdx, durationMs: 200, transition: .cut, pads: pads, ccButtons: [], sceneButtons: []))
        }
        return Project(
            version: "1.0",
            metadata: ProjectMetadata(name: "Random Sparkle", created: .distantPast, modified: .distantPast, bpm: 160, author: "Built-in"),
            targetDevice: .x,
            frames: frames
        )
    }()

    // MARK: - Warm Glow (3 frames)

    static let warmGlow: Project = {
        var frames: [Frame] = []
        let colors: [UInt8] = [9, 5, 9]
        for (frameIdx, color) in colors.enumerated() {
            var pads: [PadData] = []
            for row in 1...8 {
                for col in 1...8 {
                    let note = PadGrid.noteNumber(row: row, col: col)
                    pads.append(PadData(note: note, colorValue: .palette(color), ledMode: .pulsing))
                }
            }
            frames.append(Frame(index: frameIdx, durationMs: 1000, transition: .cut, pads: pads, ccButtons: [], sceneButtons: []))
        }
        return Project(
            version: "1.0",
            metadata: ProjectMetadata(name: "Warm Glow", created: .distantPast, modified: .distantPast, bpm: 60, author: "Built-in"),
            targetDevice: .x,
            frames: frames
        )
    }()
}
