import Foundation
import SwiftUI

@MainActor
final class TidyModel: ObservableObject {
    @Published private(set) var repos: [Repo] = []
    @Published private(set) var log: [LogLine] = []
    @Published private(set) var busy = false
    @Published private(set) var runningLabel = ""
    @Published var errorMessage: String?

    @Published var root: String {
        didSet { UserDefaults.standard.set(root, forKey: Self.rootKey) }
    }

    let script: URL?

    private static let rootKey = "tidyRoot"

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.rootKey)
        root = saved ?? FileManager.default.homeDirectoryForCurrentUser.appending(path: "personal").path
        script = Self.locateScript()
        if script == nil {
            errorMessage = "Could not find tidy-repos in ~/.local/bin, /opt/homebrew/bin or /usr/local/bin."
        }
    }

    /// GUI apps get a bare PATH, so look in the places the script actually lives.
    private static func locateScript() -> URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let candidates = [
            home.appending(path: ".local/bin/tidy-repos"),
            URL(filePath: "/opt/homebrew/bin/tidy-repos"),
            URL(filePath: "/usr/local/bin/tidy-repos"),
        ]
        return candidates.first { FileManager.default.isExecutableFile(atPath: $0.path) }
    }

    var summary: String {
        guard !repos.isEmpty else { return "No repos" }
        let dirty = repos.filter(\.dirty).count
        let behind = repos.filter { $0.behind > 0 }.count
        let worktrees = repos.reduce(0) { $0 + $1.worktrees }
        var parts = ["\(repos.count) repos"]
        if dirty > 0 { parts.append("\(dirty) dirty") }
        if behind > 0 { parts.append("\(behind) behind") }
        if worktrees > 0 { parts.append("\(worktrees) worktrees") }
        return parts.joined(separator: " · ")
    }

    func refresh() async {
        guard let script, !busy else { return }
        busy = true
        runningLabel = "Reading status…"
        defer { busy = false; runningLabel = "" }

        do {
            let output = try await Subprocess.capture(script, ["--json", root])
            let report = try JSONDecoder().decode(StatusReport.self, from: Data(output.utf8))
            repos = report.repos
            errorMessage = nil
        } catch {
            errorMessage = "Could not read status: \(error.localizedDescription)"
        }
    }

    /// Run one action over the given repos, one script invocation per repo so a
    /// failure in one repo does not take the rest down with it.
    func run(_ action: TidyAction, on targets: [Repo]) async {
        guard let script, !busy, !targets.isEmpty else { return }
        busy = true
        defer { busy = false; runningLabel = "" }

        for (index, repo) in targets.enumerated() {
            runningLabel = "\(action.title) \(repo.name) (\(index + 1)/\(targets.count))"
            let argv = action.args + [repo.path]
            append(LogLine(text: "$ tidy-repos \(argv.joined(separator: " "))", kind: .plain))
            for await chunk in Subprocess.stream(script, argv) {
                for line in chunk.split(separator: "\n", omittingEmptySubsequences: false).dropLast() {
                    append(LogLine(raw: String(line)))
                }
            }
        }

        runningLabel = "Reading status…"
        busy = false
        await refresh()
    }

    func clearLog() { log.removeAll() }

    private func append(_ line: LogLine) {
        log.append(line)
        if log.count > 2000 { log.removeFirst(log.count - 2000) }
    }
}

enum Subprocess {
    /// Run to completion and return stdout.
    static func capture(_ executable: URL, _ arguments: [String]) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                let process = Process()
                process.executableURL = executable
                process.arguments = arguments
                let out = Pipe()
                process.standardOutput = out
                process.standardError = Pipe()
                do {
                    try process.run()
                    let data = out.fileHandleForReading.readDataToEndOfFile()
                    process.waitUntilExit()
                    continuation.resume(returning: String(decoding: data, as: UTF8.self))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Run and yield output as it arrives, so long tidies show progress. Chunks
    /// are split on newlines by the caller; each yield ends on a line boundary.
    static func stream(_ executable: URL, _ arguments: [String]) -> AsyncStream<String> {
        AsyncStream { continuation in
            let process = Process()
            process.executableURL = executable
            process.arguments = arguments
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            var pending = ""
            pipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                guard !data.isEmpty else { return }
                pending += String(decoding: data, as: UTF8.self)
                guard let lastNewline = pending.lastIndex(of: "\n") else { return }
                let complete = String(pending[...lastNewline])
                pending = String(pending[pending.index(after: lastNewline)...])
                continuation.yield(complete)
            }

            process.terminationHandler = { _ in
                pipe.fileHandleForReading.readabilityHandler = nil
                let rest = pending + String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
                if !rest.isEmpty { continuation.yield(rest.hasSuffix("\n") ? rest : rest + "\n") }
                continuation.finish()
            }

            do {
                try process.run()
            } catch {
                continuation.yield("error: \(error.localizedDescription)\n")
                continuation.finish()
            }
        }
    }
}
