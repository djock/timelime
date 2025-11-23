import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: EventViewModel
    @State private var showingAddEvent = false
    @State private var showingExportImport = false
    @State private var selectedTab: EventViewModel.ViewType = .gantt

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Tab Picker
            tabPicker

            // Content
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Footer
            footerView
        }
        .frame(width: 480, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingAddEvent) {
            EventFormView(viewModel: viewModel, event: nil, isPresented: $showingAddEvent)
        }
    }

    private var headerView: some View {
        HStack {
            Text("TimeLime")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)

            Spacer()

            Button(action: { showingAddEvent = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            .buttonStyle(.plain)
            .help("Add new event")

            Button(action: { showingExportImport.toggle() }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .help("Export/Import data")
            .popover(isPresented: $showingExportImport) {
                ExportImportView(viewModel: viewModel)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var tabPicker: some View {
        Picker("View", selection: $selectedTab) {
            ForEach(EventViewModel.ViewType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            switch selectedTab {
            case .gantt:
                GanttView(viewModel: viewModel)
            case .monthly:
                MonthlyView(viewModel: viewModel)
            case .weekly:
                WeeklyView(viewModel: viewModel)
            }
        }
    }

    private var footerView: some View {
        HStack {
            Text("\(viewModel.events.count) event(s)")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Export/Import View
struct ExportImportView: View {
    @ObservedObject var viewModel: EventViewModel
    @State private var showingExporter = false
    @State private var showingImporter = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Data Management")
                .font(.headline)

            Button("Export Data") {
                exportData()
            }
            .buttonStyle(.borderedProminent)

            Button("Import Data") {
                importData()
            }

            Button("Clear All Data", role: .destructive) {
                viewModel.clearAllData()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 200)
    }

    private func exportData() {
        guard let data = viewModel.exportData() else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "timelime-export.json"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                try? data.write(to: url)
            }
        }
    }

    private func importData() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false

        openPanel.begin { response in
            if response == .OK, let url = openPanel.url,
               let data = try? Data(contentsOf: url) {
                viewModel.importData(from: data)
            }
        }
    }
}
