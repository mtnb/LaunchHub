import Foundation
import Observation

@Observable
@MainActor
final class ExportViewModel {
    var selectedFormat: ExportFormat = .launchhub
    var exportData: Data?
    var isExporting = false
    var exportError: String?

    let project: Project
    private let storageService: ProjectStorageService

    init(project: Project, storageService: ProjectStorageService = ProjectStorageService()) {
        self.project = project
        self.storageService = storageService
    }

    func generateExport() {
        isExporting = true
        exportError = nil
        do {
            exportData = try storageService.exportData(project, format: selectedFormat)
        } catch {
            exportError = error.localizedDescription
        }
        isExporting = false
    }

    var fileName: String {
        "\(project.metadata.name).\(selectedFormat.fileExtension)"
    }

    var exportURL: URL? {
        guard let data = exportData else { return nil }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: tempURL)
        return tempURL
    }
}
