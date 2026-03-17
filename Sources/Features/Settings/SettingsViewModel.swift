import Foundation
import Observation

@Observable
@MainActor
final class SettingsViewModel {
    let storageService: ProjectStorageService
    var showDeleteConfirmation = false

    init(storageService: ProjectStorageService) {
        self.storageService = storageService
    }

    func deleteAllData() {
        let allProjects = (try? storageService.loadAll()) ?? []
        for project in allProjects {
            try? storageService.delete(name: project.metadata.name)
        }
    }
}
