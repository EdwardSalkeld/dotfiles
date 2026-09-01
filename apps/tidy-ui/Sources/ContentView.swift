import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var model: TidyModel
    @State private var selection = Set<Repo.ID>()
    @State private var sortOrder = [KeyPathComparator(\Repo.name)]
    @State private var pickingRoot = false
    @State private var confirming: TidyAction?

    private var sorted: [Repo] {
        model.repos.sorted(using: sortOrder)
    }

    /// Actions apply to the selection, or to everything when nothing is picked.
    private var targets: [Repo] {
        selection.isEmpty ? sorted : sorted.filter { selection.contains($0.id) }
    }

    private var targetLabel: String {
        selection.isEmpty ? "all \(model.repos.count)" : "\(selection.count) selected"
    }

    var body: some View {
        VStack(spacing: 0) {
            VSplitView {
                table
                    .frame(minHeight: 240)
                    .layoutPriority(1)
                LogView()
                    .frame(minHeight: 90, idealHeight: 140)
            }
            Divider()
            statusBar
        }
        .toolbar { toolbar }
        .task { await model.refresh() }
        .fileImporter(isPresented: $pickingRoot, allowedContentTypes: [.folder]) { result in
            if case .success(let url) = result {
                model.root = url.path
                Task { await model.refresh() }
            }
        }
        .confirmationDialog(
            "Hard prune \(targetLabel)?",
            isPresented: Binding(get: { confirming != nil }, set: { if !$0 { confirming = nil } }),
            presenting: confirming
        ) { action in
            Button("Hard prune", role: .destructive) {
                let repos = targets
                confirming = nil
                Task { await model.run(action, on: repos) }
            }
            Button("Cancel", role: .cancel) { confirming = nil }
        } message: { action in
            Text(action.help)
        }
        .alert("tidy-repos", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )) {
            Button("OK") { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }

    private var table: some View {
        Table(sorted, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Repo", value: \.name) { repo in
                HStack(spacing: 6) {
                    Image(systemName: repo.dirty ? "pencil.circle.fill" : "folder")
                        .foregroundStyle(repo.dirty ? .orange : .secondary)
                        .help(repo.dirty ? "Uncommitted changes" : "Clean")
                    Text(repo.name)
                }
            }
            .width(min: 160, ideal: 200)

            TableColumn("Branch", value: \.branch) { repo in
                Text(repo.displayBranch)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(repo.branch.isEmpty ? .secondary : .primary)
                    .help(repo.displayBranch)
            }
            .width(min: 120, ideal: 160)

            TableColumn("Sync", value: \.sync.rank) { repo in
                Label(repo.sync.label, systemImage: repo.sync.symbol)
                    .foregroundStyle(color(for: repo.sync))
            }
            .width(min: 130, ideal: 160)

            TableColumn("Last commit", value: \.date) { repo in
                Text(repo.relative)
                    .foregroundStyle(.secondary)
                    .help(repo.date)
            }
            .width(min: 100, ideal: 130)

            TableColumn("Worktrees", value: \.worktrees) { repo in
                Text(repo.worktrees == 0 ? "—" : "\(repo.worktrees)")
                    .foregroundStyle(repo.worktrees == 0 ? .secondary : .primary)
            }
            .width(min: 70, ideal: 80)

            TableColumn("Branches", value: \.branches) { repo in
                Text("\(repo.branches)")
                    .foregroundStyle(repo.branches > 1 ? .primary : .secondary)
            }
            .width(min: 70, ideal: 80)
        }
        .contextMenu(forSelectionType: Repo.ID.self) { ids in
            ForEach(TidyAction.all) { action in
                Button(action.title) { perform(action, on: repos(for: ids)) }
            }
            Divider()
            Button("Reveal in Finder") {
                let urls = repos(for: ids).map { URL(filePath: $0.path) }
                NSWorkspace.shared.activateFileViewerSelecting(urls)
            }
        } primaryAction: { ids in
            let urls = repos(for: ids).map { URL(filePath: $0.path) }
            NSWorkspace.shared.activateFileViewerSelecting(urls)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                pickingRoot = true
            } label: {
                Label((model.root as NSString).abbreviatingWithTildeInPath, systemImage: "folder")
            }
            .help("Choose the directory of repos")
        }

        ToolbarItem {
            Button {
                Task { await model.refresh() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .labelStyle(.titleAndIcon)
            .keyboardShortcut("r")
            .disabled(model.busy)
            .help("Re-read status. Does not fetch.")
        }

        ToolbarItemGroup {
            ForEach(TidyAction.all) { action in
                Button {
                    perform(action, on: targets)
                } label: {
                    Label(action.title, systemImage: action.symbol)
                }
                .labelStyle(.titleAndIcon)
                .tint(action.destructive ? .red : nil)
                .disabled(model.busy || model.repos.isEmpty)
                .help("\(action.help) Applies to \(targetLabel).")
            }
        }
    }

    private var statusBar: some View {
        HStack(spacing: 8) {
            if model.busy {
                ProgressView().controlSize(.small)
                Text(model.runningLabel)
            } else {
                Text(model.summary)
                Text("·").foregroundStyle(.tertiary)
                Text("sync shown as of the last fetch")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(selection.isEmpty ? "Actions apply to all repos" : "\(selection.count) selected")
                .foregroundStyle(.secondary)
        }
        .font(.callout)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.bar)
    }

    private func repos(for ids: Set<Repo.ID>) -> [Repo] {
        ids.isEmpty ? targets : sorted.filter { ids.contains($0.id) }
    }

    private func perform(_ action: TidyAction, on repos: [Repo]) {
        if action.destructive {
            confirming = action
        } else {
            Task { await model.run(action, on: repos) }
        }
    }

    private func color(for sync: SyncState) -> Color {
        switch sync {
        case .upToDate: return .green
        case .behind, .diverged: return .orange
        case .ahead: return .blue
        case .noUpstream: return .secondary
        }
    }
}

struct LogView: View {
    @EnvironmentObject private var model: TidyModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Output").font(.headline)
                Spacer()
                Button("Clear", action: model.clearLog)
                    .buttonStyle(.link)
                    .disabled(model.log.isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        if model.log.isEmpty {
                            Text("Run an action to see what the script does.")
                                .foregroundStyle(.secondary)
                                .padding(12)
                        }
                        ForEach(model.log) { line in
                            Text(line.text.isEmpty ? " " : line.text)
                                .font(.system(.caption, design: .monospaced))
                                .fontWeight(line.kind == .heading ? .bold : .regular)
                                .foregroundStyle(style(for: line.kind))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(line.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .textSelection(.enabled)
                }
                .onChange(of: model.log.count) {
                    if let last = model.log.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private func style(for kind: LogLine.Kind) -> Color {
        switch kind {
        case .heading: return .primary
        case .good: return .green
        case .warn: return .orange
        case .quiet: return .secondary
        case .plain: return .secondary
        }
    }
}
