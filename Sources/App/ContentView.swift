import SwiftUI

struct ContentView: View {
    @Environment(MIDIService.self) private var midiService
    @Environment(ProjectStorageService.self) private var storageService
    @Environment(AppSettings.self) private var appSettings

    @State private var selectedTab = 0
    @State private var activeProject: Project?
    @State private var showDeviceConnection = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeTab(
                storageService: storageService,
                connectedDevice: midiService.connectedDevice,
                selectedTab: $selectedTab,
                activeProject: $activeProject,
                showDeviceConnection: $showDeviceConnection
            )
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)

            // Editor Tab
            Group {
                if let project = activeProject {
                    EditorView(
                        viewModel: EditorViewModel(
                            project: project,
                            storageService: storageService,
                            ledController: LEDController(midiService: midiService)
                        )
                    )
                } else {
                    VStack(spacing: Spacing.lg) {
                        Image(systemName: "pianokeys")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.textTertiary)
                        Text("No project open")
                            .font(.bodyText)
                            .foregroundStyle(Color.textSecondary)
                        ActionButton(title: "Create New Project", style: .primary) {
                            let project = Project.new()
                            try? storageService.save(project)
                            activeProject = project
                        }
                        .frame(maxWidth: 240)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.surface0)
                }
            }
            .tabItem {
                Label("Edit", systemImage: "pianokeys")
            }
            .tag(1)

            // Library Tab
            LibraryView(
                viewModel: LibraryViewModel(storageService: storageService),
                onOpenProject: { project in
                    activeProject = project
                    selectedTab = 1
                }
            )
            .tabItem {
                Label("Lib", systemImage: "folder")
            }
            .tag(2)

            // Settings Tab
            SettingsView(
                viewModel: SettingsViewModel(storageService: storageService),
                onShowDeviceConnection: { showDeviceConnection = true }
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(3)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showDeviceConnection) {
            DeviceConnectionView(
                viewModel: DeviceConnectionViewModel(
                    midiService: midiService,
                    ledController: LEDController(midiService: midiService)
                )
            )
        }
    }
}

/// Wrapper that owns the HomeViewModel via @State so it persists across tab switches
private struct HomeTab: View {
    let storageService: ProjectStorageService
    let connectedDevice: ConnectedDevice?
    @Binding var selectedTab: Int
    @Binding var activeProject: Project?
    @Binding var showDeviceConnection: Bool

    @State private var viewModel: HomeViewModel?

    var body: some View {
        Group {
            if let viewModel {
                HomeView(
                    viewModel: viewModel,
                    connectedDevice: connectedDevice,
                    onOpenProject: { project in
                        activeProject = project
                        selectedTab = 1
                    },
                    onShowDeviceConnection: { showDeviceConnection = true }
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HomeViewModel(storageService: storageService)
            }
            viewModel?.loadProjects()
        }
    }
}

#Preview {
    ContentView()
        .environment(MIDIService())
        .environment(ProjectStorageService())
        .environment(AppSettings())
}
