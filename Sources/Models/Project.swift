import Foundation

struct Project: Codable, Sendable, Equatable, Identifiable {
    var id: String { metadata.name + metadata.created.timeIntervalSince1970.description }

    var version: String
    var metadata: ProjectMetadata
    var targetDevice: LaunchpadModel
    var frames: [Frame]

    enum CodingKeys: String, CodingKey {
        case version
        case metadata
        case targetDevice = "target_device"
        case frames
    }

    static func new(name: String = "Untitled", device: LaunchpadModel = .x) -> Project {
        Project(
            version: "1.0",
            metadata: .default(name: name),
            targetDevice: device,
            frames: [Frame.blank(index: 0)]
        )
    }
}
