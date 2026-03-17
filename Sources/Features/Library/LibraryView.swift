import SwiftUI

struct LibraryView: View {
    @State var viewModel: LibraryViewModel
    var onOpenProject: (Project) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter
                Picker("Filter", selection: $viewModel.selectedFilter) {
                    ForEach(LibraryViewModel.Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)

                // Preset list
                List {
                    ForEach(viewModel.filteredPresets) { preset in
                        presetRow(preset)
                            .listRowBackground(Color.surface1)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.surface0)
            }
            .background(Color.surface0)
            .navigationTitle("Library")
            .searchable(text: $viewModel.searchText, prompt: "Search presets")
            .onAppear {
                viewModel.loadUserPresets()
            }
        }
    }

    private func presetRow(_ preset: Project) -> some View {
        HStack(spacing: Spacing.md) {
            // Thumbnail
            if let firstFrame = preset.frames.first {
                FrameThumbnail(frame: firstFrame, isSelected: false)
                    .frame(width: 60, height: 60)
            }

            // Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(preset.metadata.name)
                    .font(.bodyText)
                    .foregroundStyle(Color.textPrimary)

                HStack(spacing: Spacing.sm) {
                    Text("\(preset.frames.count) frames")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                    Text("\(preset.metadata.bpm) BPM")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Text(preset.metadata.author)
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer()

            Button("Use") {
                let project = viewModel.openInEditor(preset)
                onOpenProject(project)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentPrimary)
        }
        .padding(.vertical, Spacing.xs)
    }
}
