import Foundation
import Observation

@Observable
@MainActor
final class LibraryViewModel {
    enum Filter: String, CaseIterable {
        case all = "All"
        case builtIn = "Built-in"
        case my = "My"
    }

    var selectedFilter: Filter = .all
    var searchText: String = ""
    var builtInPresets: [Project] = BuiltInPresets.all
    var userPresets: [Project] = []

    private let storageService: ProjectStorageService

    init(storageService: ProjectStorageService) {
        self.storageService = storageService
    }

    var filteredPresets: [Project] {
        let all: [Project]
        switch selectedFilter {
        case .all:
            all = builtInPresets + userPresets
        case .builtIn:
            all = builtInPresets
        case .my:
            all = userPresets
        }

        if searchText.isEmpty {
            return all
        }
        return all.filter { $0.metadata.name.localizedCaseInsensitiveContains(searchText) }
    }

    func loadUserPresets() {
        userPresets = (try? storageService.loadAll()) ?? []
    }

    func openInEditor(_ preset: Project) -> Project {
        var copy = preset
        copy.metadata.name = "\(preset.metadata.name) Copy"
        let now = Date()
        copy.metadata.created = now
        copy.metadata.modified = now
        try? storageService.save(copy)
        return copy
    }
}
