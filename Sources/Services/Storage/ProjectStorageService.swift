import Foundation

@Observable
@MainActor
final class ProjectStorageService {
    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - CRUD Operations

    func save(_ project: Project) throws {
        let data = try encoder.encode(project)
        let fileURL = fileURL(for: project)
        try data.write(to: fileURL, options: .atomic)
    }

    func load(name: String) throws -> Project {
        let fileURL = documentsDirectory.appendingPathComponent("\(name).launchhub")
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(Project.self, from: data)
    }

    func loadAll() throws -> [Project] {
        let contents = try fileManager.contentsOfDirectory(
            at: documentsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        )
        let projectFiles = contents.filter { $0.pathExtension == "launchhub" }
        return projectFiles.compactMap { url in
            guard let data = try? Data(contentsOf: url),
                  let project = try? decoder.decode(Project.self, from: data)
            else { return nil }
            return project
        }
        .sorted { $0.metadata.modified > $1.metadata.modified }
    }

    func delete(name: String) throws {
        let fileURL = documentsDirectory.appendingPathComponent("\(name).launchhub")
        try fileManager.removeItem(at: fileURL)
    }

    func duplicate(_ project: Project) throws -> Project {
        var copy = project
        copy.metadata.name = "\(project.metadata.name) Copy"
        let now = Date()
        copy.metadata.created = now
        copy.metadata.modified = now
        try save(copy)
        return copy
    }

    func exportData(_ project: Project, format: ExportFormat) throws -> Data {
        switch format {
        case .launchhub, .json:
            return try encoder.encode(project)
        case .midi:
            return try MIDIExporter.export(project)
        }
    }

    // MARK: - Helpers

    private func fileURL(for project: Project) -> URL {
        documentsDirectory.appendingPathComponent("\(project.metadata.name).launchhub")
    }
}

// MARK: - Simple MIDI Export

enum MIDIExporter {
    static func export(_ project: Project) throws -> Data {
        var bytes: [UInt8] = []

        // MThd header
        bytes += [0x4D, 0x54, 0x68, 0x64] // "MThd"
        bytes += [0x00, 0x00, 0x00, 0x06] // Header length
        bytes += [0x00, 0x00]             // Format 0
        bytes += [0x00, 0x01]             // 1 track
        let ppq: UInt16 = 480
        bytes += [UInt8(ppq >> 8), UInt8(ppq & 0xFF)]

        // MTrk
        var trackBytes: [UInt8] = []

        // Set tempo
        let tempo = 60_000_000 / project.metadata.bpm
        trackBytes += [0x00, 0xFF, 0x51, 0x03]
        trackBytes += [
            UInt8((tempo >> 16) & 0xFF),
            UInt8((tempo >> 8) & 0xFF),
            UInt8(tempo & 0xFF),
        ]

        // Write frames as note events
        for frame in project.frames {
            // Delta time 0 for first event in frame
            for pad in frame.pads {
                trackBytes += [0x00] // delta
                let channel = pad.ledMode.midiChannel
                let statusOn: UInt8 = 0x90 | channel
                switch pad.colorValue {
                case .palette(let vel):
                    trackBytes += [statusOn, pad.note, vel]
                case .rgb(_, _, _):
                    trackBytes += [statusOn, pad.note, 127]
                }
            }

            // Duration as delta time
            let ticks = durationToTicks(ms: frame.durationMs, bpm: project.metadata.bpm, ppq: Int(ppq))
            let deltaBytes = variableLengthQuantity(ticks)

            // Note offs
            for (i, pad) in frame.pads.enumerated() {
                let delta: [UInt8] = i == 0 ? deltaBytes : [0x00]
                trackBytes += delta
                trackBytes += [0x80 | pad.ledMode.midiChannel, pad.note, 0x00]
            }
        }

        // End of track
        trackBytes += [0x00, 0xFF, 0x2F, 0x00]

        bytes += [0x4D, 0x54, 0x72, 0x6B] // "MTrk"
        let trackLen = UInt32(trackBytes.count)
        bytes += [
            UInt8((trackLen >> 24) & 0xFF),
            UInt8((trackLen >> 16) & 0xFF),
            UInt8((trackLen >> 8) & 0xFF),
            UInt8(trackLen & 0xFF),
        ]
        bytes += trackBytes

        return Data(bytes)
    }

    private static func durationToTicks(ms: Int, bpm: Int, ppq: Int) -> Int {
        let msPerBeat = 60000.0 / Double(bpm)
        let beats = Double(ms) / msPerBeat
        return Int(beats * Double(ppq))
    }

    private static func variableLengthQuantity(_ value: Int) -> [UInt8] {
        if value == 0 { return [0x00] }
        var result: [UInt8] = []
        var v = value
        result.append(UInt8(v & 0x7F))
        v >>= 7
        while v > 0 {
            result.append(UInt8((v & 0x7F) | 0x80))
            v >>= 7
        }
        return result.reversed()
    }
}
