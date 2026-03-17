import SwiftUI

struct EditorView: View {
    @State var viewModel: EditorViewModel
    @State private var showColorPicker = false
    @State private var showExport = false
    @Environment(AppSettings.self) private var settings

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Grid
                LaunchpadGridView(
                    viewModel: viewModel,
                    showNoteNumbers: settings.showNoteNumbers
                )

                // Toolbar
                EditorToolbar(viewModel: viewModel) {
                    showColorPicker = true
                }

                // Timeline
                FrameTimeline(viewModel: viewModel)
            }
            .background(Color.surface0)
            .navigationTitle(viewModel.project.metadata.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.togglePlayback) {
                        Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Export") { showExport = true }
                        Button("Save") { viewModel.save() }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerView(
                    selectedColor: $viewModel.selectedColor,
                    selectedLEDMode: $viewModel.selectedLEDMode
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showExport) {
                ExportView(project: viewModel.project)
            }
        }
    }
}
