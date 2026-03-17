import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    var projects: [Project] = []
    var isLoading = false

    private let storageService: ProjectStorageService

    init(storageService: ProjectStorageService) {
        self.storageService = storageService
    }

    func loadProjects() {
        isLoading = true
        projects = (try? storageService.loadAll()) ?? []
        isLoading = false
    }

    func createNewProject(name: String = "Untitled") -> Project {
        let project = Project.new(name: name)
        try? storageService.save(project)
        loadProjects()
        return project
    }

    func deleteProject(_ project: Project) {
        try? storageService.delete(name: project.metadata.name)
        loadProjects()
    }

    func duplicateProject(_ project: Project) {
        _ = try? storageService.duplicate(project)
        loadProjects()
    }
}
