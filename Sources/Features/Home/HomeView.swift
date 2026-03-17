import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @State private var showDeviceConnection = false
    @State private var showNewProject = false
    @State private var newProjectName = ""

    var connectedDevice: ConnectedDevice?
    var onOpenProject: (Project) -> Void
    var onShowDeviceConnection: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Device status
                    deviceStatusSection

                    // Recent projects
                    recentProjectsSection

                    // Quick actions
                    quickActionsSection
                }
                .padding(Spacing.md)
            }
            .background(Color.surface0)
            .navigationTitle("LaunchHub")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewProject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New Project", isPresented: $showNewProject) {
                TextField("Project Name", text: $newProjectName)
                Button("Create") {
                    let name = newProjectName.isEmpty ? "Untitled" : newProjectName
                    let project = viewModel.createNewProject(name: name)
                    newProjectName = ""
                    onOpenProject(project)
                }
                Button("Cancel", role: .cancel) {
                    newProjectName = ""
                }
            }
            .onAppear {
                viewModel.loadProjects()
            }
        }
    }

    // MARK: - Device Status

    private var deviceStatusSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if let device = connectedDevice {
                DeviceCard(
                    modelName: device.name,
                    connectionState: "Connected",
                    connectionType: device.connectionType.rawValue,
                    firmwareVersion: device.firmwareVersion,
                    isConnected: true
                )
                .onTapGesture { onShowDeviceConnection() }
            } else {
                DeviceCard(
                    modelName: "No Device",
                    connectionState: "Tap to connect",
                    connectionType: "",
                    firmwareVersion: nil,
                    isConnected: false
                )
                .onTapGesture { onShowDeviceConnection() }
            }
        }
    }

    // MARK: - Recent Projects

    private var recentProjectsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent Projects")
                .font(.sectionHeading)
                .foregroundStyle(Color.textPrimary)

            if viewModel.projects.isEmpty {
                Text("No projects yet. Create one to get started!")
                    .font(.bodyText)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.vertical, Spacing.md)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(viewModel.projects.prefix(6)) { project in
                            projectCard(project)
                        }

                        // New project card
                        Button {
                            showNewProject = true
                        } label: {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundStyle(Color.accentPrimary)
                                Text("New")
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            .frame(width: 120, height: 140)
                            .background(Color.surface1)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }

    private func projectCard(_ project: Project) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Mini grid preview
            if let firstFrame = project.frames.first {
                FrameThumbnail(frame: firstFrame, isSelected: false)
                    .frame(width: 120, height: 90)
            }

            Text(project.metadata.name)
                .font(.caption)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)

            Text(project.metadata.modified, style: .relative)
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(width: 120)
        .padding(Spacing.sm)
        .background(Color.surface1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            onOpenProject(project)
        }
        .contextMenu {
            Button("Duplicate") { viewModel.duplicateProject(project) }
            Button("Delete", role: .destructive) { viewModel.deleteProject(project) }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Quick Actions")
                .font(.sectionHeading)
                .foregroundStyle(Color.textPrimary)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: Spacing.sm) {
                quickActionButton(icon: "antenna.radiowaves.left.and.right", title: "Device Connection") {
                    onShowDeviceConnection()
                }
                quickActionButton(icon: "folder", title: "Presets") {
                    // Navigate to library tab
                }
            }
        }
    }

    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.accentPrimary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.surface1)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
