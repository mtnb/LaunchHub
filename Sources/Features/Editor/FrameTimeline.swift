import SwiftUI

struct FrameTimeline: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Frame thumbnails
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(viewModel.project.frames) { frame in
                            FrameThumbnail(
                                frame: frame,
                                isSelected: frame.index == viewModel.selectedFrameIndex
                            )
                            .id(frame.index)
                            .frame(width: 64, height: 90)
                            .onTapGesture {
                                viewModel.selectFrame(at: frame.index)
                            }
                            .contextMenu {
                                Button("Duplicate") { viewModel.duplicateFrame() }
                                Button("Delete", role: .destructive) { viewModel.deleteFrame() }
                            }
                        }

                        // Add button
                        Button(action: viewModel.addFrame) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.title3)
                                    .foregroundStyle(Color.accentPrimary)
                                Text("Add")
                                    .font(.caption2)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            .frame(width: 64, height: 90)
                            .background(Color.surface2)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .onChange(of: viewModel.selectedFrameIndex) { _, newValue in
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }

            // Duration editor
            HStack {
                Text("Frame \(viewModel.selectedFrameIndex + 1) / \(viewModel.frameCount)")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                HStack(spacing: Spacing.xs) {
                    Text("Duration:")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                    TextField("ms", value: Binding(
                        get: { viewModel.currentFrame.durationMs },
                        set: { viewModel.currentFrame.durationMs = max(50, min(10000, $0)) }
                    ), format: .number)
                    .font(.caption.monospacedDigit())
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    Text("ms")
                        .font(.caption)
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.sm)
        .background(Color.surface1)
    }
}
