import Foundation

struct ProjectMetadata: Codable, Sendable, Equatable {
    var name: String
    var created: Date
    var modified: Date
    var bpm: Int
    var author: String

    static func `default`(name: String = "Untitled") -> ProjectMetadata {
        let now = Date()
        return ProjectMetadata(
            name: name,
            created: now,
            modified: now,
            bpm: 120,
            author: ""
        )
    }
}
