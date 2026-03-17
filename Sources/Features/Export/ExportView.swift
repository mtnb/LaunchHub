import SwiftUI

struct ExportView: View {
    let project: Project
    @State private var viewModel: ExportViewModel?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                // Preview
                projectPreview

                // Format selection
                formatSelection

                // Export button
                if let vm = viewModel {
                    if let url = vm.exportURL {
                        ShareLink(item: url) {
                            Text("Share")
                                .font(.buttonLabel)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.accentPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, Spacing.md)
                    }

                    if let error = vm.exportError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.accentDanger)
                    }

                    ActionButton(title: "Generate Export", style: .primary) {
                        vm.generateExport()
                    }
                    .padding(.horizontal, Spacing.md)
                }

                Spacer()
            }
            .padding(.vertical, Spacing.md)
            .background(Color.surface0)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                viewModel = ExportViewModel(project: project)
            }
        }
    }

    // MARK: - Preview

    private var projectPreview: some View {
        HStack(spacing: Spacing.md) {
            if let firstFrame = project.frames.first {
                FrameThumbnail(frame: firstFrame, isSelected: false)
                    .frame(width: 60, height: 60)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(project.metadata.name)
                    .font(.sectionHeading)
                    .foregroundStyle(Color.textPrimary)

                HStack(spacing: Spacing.sm) {
                    Text("\(project.frames.count) frames")
                    Text("\(project.metadata.bpm) BPM")
                }
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.surface1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Format Selection

    private var formatSelection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Format")
                .font(.sectionHeading)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.md)

            ForEach(ExportFormat.allCases, id: \.self) { format in
                Button {
                    viewModel?.selectedFormat = format
                    viewModel?.exportData = nil
                } label: {
                    HStack {
                        Image(systemName: viewModel?.selectedFormat == format ? "circle.inset.filled" : "circle")
                            .foregroundStyle(Color.accentPrimary)
                        Text(format.displayName)
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                    }
                    .padding(Spacing.md)
                    .background(Color.surface1)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
}
