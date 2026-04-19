import Foundation
import Observation

/// Detects the system-level prerequisites OpenClaw itself expects —
/// currently Node.js (>= 22.14, or any 24.x) and Homebrew for the
/// one-click fix. The service is deliberately shell-only and never
/// touches the network; it just reads `node -v` and `brew -v` so the
/// install screen can tell a newbie "you're missing Node" before they
/// hit the guided setup and get a cryptic OpenClaw error.
@MainActor
@Observable
final class SystemPrereqChecker {
    struct NodeStatus: Equatable {
        enum State: Equatable {
            case missing
            case tooOld(found: String, minimum: String)
            case ok(version: String)
        }
        var state: State
        var rawVersion: String?
    }

    struct BrewStatus: Equatable {
        var isInstalled: Bool
        var version: String?
    }

    /// Minimum supported Node as documented by OpenClaw (22.14 or any 24).
    static let minimumNodeMajor = 22
    static let minimumNodeMinor = 14

    private(set) var node: NodeStatus = NodeStatus(state: .missing, rawVersion: nil)
    private(set) var brew: BrewStatus = BrewStatus(isInstalled: false, version: nil)
    private(set) var lastCheckedAt: Date?
    private(set) var isChecking: Bool = false

    var allGreen: Bool {
        if case .ok = node.state { return true }
        return false
    }

    func refresh() {
        isChecking = true
        Task { @MainActor in
#if APPSTORE_BUILD
            // Sandboxed builds cannot spawn `node -v` / `brew -v`, so
            // we surface a friendly "unknown" state instead of a false
            // negative. The install wizard is also hidden in this
            // flavor, so this state is mostly informational.
            self.node = NodeStatus(state: .missing, rawVersion: nil)
            self.brew = BrewStatus(isInstalled: false, version: nil)
#else
            let node = Self.detectNode()
            let brew = Self.detectBrew()
            self.node = node
            self.brew = brew
#endif
            self.lastCheckedAt = Date()
            self.isChecking = false
        }
    }

    // MARK: - Detection

#if !APPSTORE_BUILD
    private static func detectNode() -> NodeStatus {
        // GUI apps don't inherit the user's interactive PATH, so nvm /
        // fnm / asdf shims are invisible to `/usr/bin/env node`. Running
        // through a login shell picks up ~/.zprofile / ~/.zshrc exports
        // the same way Terminal does, which is what the user expects.
        let raw = loginShellOutput("command -v node >/dev/null 2>&1 && node -v").trimmed
        guard !raw.isEmpty else {
            return NodeStatus(state: .missing, rawVersion: nil)
        }
        // `node -v` prints e.g. "v22.14.0"
        let trimmed = raw.hasPrefix("v") ? String(raw.dropFirst()) : raw
        let parts = trimmed.split(separator: ".").compactMap { Int($0) }
        guard let major = parts.first else {
            return NodeStatus(state: .tooOld(found: raw, minimum: "v\(minimumNodeMajor).\(minimumNodeMinor)"), rawVersion: raw)
        }
        let minor = parts.count > 1 ? parts[1] : 0

        // OpenClaw supports 22.14+ LTS, or any 24.x. 23.x is treated as
        // unsupported between the two LTS lines.
        if major >= 24 {
            return NodeStatus(state: .ok(version: raw), rawVersion: raw)
        }
        if major == 22 && minor >= minimumNodeMinor {
            return NodeStatus(state: .ok(version: raw), rawVersion: raw)
        }
        return NodeStatus(
            state: .tooOld(found: raw, minimum: "v\(minimumNodeMajor).\(minimumNodeMinor)"),
            rawVersion: raw
        )
    }

    private static func detectBrew() -> BrewStatus {
        let raw = loginShellOutput("command -v brew >/dev/null 2>&1 && brew -v").trimmed
        guard !raw.isEmpty else {
            return BrewStatus(isInstalled: false, version: nil)
        }
        // First line is "Homebrew 4.x.y".
        let firstLine = raw.split(separator: "\n").first.map(String.init) ?? raw
        return BrewStatus(isInstalled: true, version: firstLine)
    }

    /// Runs a short command through `/bin/bash -lc` so user-profile PATH
    /// (nvm, fnm, asdf, Homebrew on Apple Silicon) resolves the same way
    /// it would in Terminal. Falls back silently when the shell errors.
    private static func loginShellOutput(_ command: String) -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-lc", command]
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self)
        } catch {
            return ""
        }
    }
#endif
}
