import Foundation

/// One repo as reported by `tidy-repos --json`.
struct Repo: Decodable, Identifiable, Hashable {
    let name: String
    let path: String
    let branch: String
    let date: String
    let relative: String
    let upstream: String
    let ahead: Int
    let behind: Int
    let dirty: Bool
    let worktrees: Int
    let branches: Int

    var id: String { path }

    var displayBranch: String { branch.isEmpty ? "(detached)" : branch }

    var sync: SyncState {
        if upstream.isEmpty { return .noUpstream }
        switch (ahead, behind) {
        case (0, 0): return .upToDate
        case (let a, 0): return .ahead(a)
        case (0, let b): return .behind(b)
        case (let a, let b): return .diverged(ahead: a, behind: b)
        }
    }
}

enum SyncState: Hashable {
    case upToDate
    case ahead(Int)
    case behind(Int)
    case diverged(ahead: Int, behind: Int)
    case noUpstream

    var label: String {
        switch self {
        case .upToDate: return "up to date"
        case .ahead(let a): return "ahead \(a)"
        case .behind(let b): return "behind \(b)"
        case .diverged(let a, let b): return "ahead \(a), behind \(b)"
        case .noUpstream: return "no upstream"
        }
    }

    var symbol: String {
        switch self {
        case .upToDate: return "checkmark.circle"
        case .ahead: return "arrow.up.circle"
        case .behind: return "arrow.down.circle"
        case .diverged: return "arrow.triangle.branch"
        case .noUpstream: return "circle.dashed"
        }
    }

    /// Sort key, so the rows that want attention float to the top.
    var rank: Int {
        switch self {
        case .diverged: return 0
        case .behind: return 1
        case .ahead: return 2
        case .noUpstream: return 3
        case .upToDate: return 4
        }
    }
}

struct StatusReport: Decodable {
    let root: String
    let repos: [Repo]
}

/// A run of the script: the flags, plus how to describe it in the UI.
struct TidyAction: Identifiable, Hashable {
    let id: String
    let title: String
    let symbol: String
    let help: String
    let args: [String]
    let destructive: Bool

    static let fetch = TidyAction(
        id: "fetch", title: "Fetch", symbol: "arrow.triangle.2.circlepath",
        help: "Fetch every repo and preview what freshening would do. Changes nothing.",
        args: ["--fresh"], destructive: false)

    static let preview = TidyAction(
        id: "preview", title: "Preview", symbol: "eye",
        help: "Show which worktrees and branches a tidy would remove. Changes nothing.",
        args: [], destructive: false)

    static let tidy = TidyAction(
        id: "tidy", title: "Tidy", symbol: "sparkles",
        help: "Remove clean worktrees and branches that are pushed or merged.",
        args: ["-x"], destructive: false)

    static let freshen = TidyAction(
        id: "freshen", title: "Freshen", symbol: "arrow.down.to.line",
        help: "Switch to the default branch and pull it fast-forward-only.",
        args: ["-x", "--fresh"], destructive: false)

    static let hard = TidyAction(
        id: "hard", title: "Hard prune", symbol: "trash",
        help: "Freshen, then force-delete every non-default branch — pushed or not.",
        args: ["-x", "--fresh", "--hard"], destructive: true)

    static let all: [TidyAction] = [.fetch, .preview, .tidy, .freshen, .hard]
}

/// A line of script output, tagged so the log can colour it.
struct LogLine: Identifiable {
    enum Kind { case heading, good, warn, quiet, plain }

    let id = UUID()
    let text: String
    let kind: Kind

    init(raw: String) {
        let stripped = LogLine.stripANSI(raw)
        text = stripped
        let body = stripped.trimmingCharacters(in: .whitespaces)
        if stripped.isEmpty {
            kind = .plain
        } else if !stripped.hasPrefix(" ") && !body.hasPrefix("$") {
            kind = .heading
        } else if LogLine.starts(body, with: ["removed", "deleted", "pulled", "packed", "switched"]) {
            kind = .good
        } else if LogLine.starts(body, with: ["kept", "keep", "not switching", "could not", "fetch failed", "pull skipped", "error"]) {
            kind = .warn
        } else if body.hasPrefix("would") {
            kind = .quiet
        } else {
            kind = .plain
        }
    }

    init(text: String, kind: Kind) {
        self.text = text
        self.kind = kind
    }

    private static func starts(_ body: String, with prefixes: [String]) -> Bool {
        prefixes.contains { body.lowercased().hasPrefix($0) }
    }

    private static let ansi = try! NSRegularExpression(pattern: "\u{1B}\\[[0-9;]*m")

    static func stripANSI(_ s: String) -> String {
        let range = NSRange(s.startIndex..., in: s)
        return ansi.stringByReplacingMatches(in: s, range: range, withTemplate: "")
    }
}
