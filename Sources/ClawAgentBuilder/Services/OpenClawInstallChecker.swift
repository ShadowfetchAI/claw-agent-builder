import Foundation

enum OpenClawReadiness {
    case notInstalled
    case installedNotOnboarded
    case partiallyConfigured
    case ready

    var title: String {
        switch self {
        case .notInstalled:
            return "OpenClaw not detected"
        case .installedNotOnboarded:
            return "OpenClaw installed, onboarding not finished"
        case .partiallyConfigured:
            return "OpenClaw found, but the setup looks partial"
        case .ready:
            return "OpenClaw looks ready"
        }
    }
}

struct OpenClawInstallStatus {
    let readiness: OpenClawReadiness
    let cliPath: String?
    let configPath: String
    let workspacePath: String
    let summary: String
    let recommendation: String

    static let unknown = OpenClawInstallStatus(
        readiness: .notInstalled,
        cliPath: nil,
        configPath: "~/.openclaw/openclaw.json",
        workspacePath: "~/.openclaw/workspace",
        summary: "OpenClaw has not been checked yet.",
        recommendation: "Refresh the install check once you have the app open."
    )
}

enum OpenClawInstallChecker {
    private static let configRelativePath = ".openclaw/openclaw.json"
    private static let workspaceRelativePath = ".openclaw/workspace"

    static func detect() -> OpenClawInstallStatus {
#if APPSTORE_BUILD
        // Sandboxed builds cannot probe the CLI or peek at ~/.openclaw
        // without a user-granted security-scoped bookmark. Return a
        // read-only "unknown" status — the install wizard is hidden in
        // this flavor, so this is only consulted by downstream code
        // paths that need some status to render.
        return OpenClawInstallStatus(
            readiness: .notInstalled,
            cliPath: nil,
            configPath: "~/.openclaw/openclaw.json",
            workspacePath: "~/.openclaw/workspace",
            summary: "OpenClaw install state isn't checked in the App Store edition. Install OpenClaw yourself in Terminal, then use this app to generate your agent files into a folder you choose.",
            recommendation: "Follow docs.openclaw.ai to install, then pick your workspace folder when you export here."
        )
#else
        let fileManager = FileManager.default
        let homeDirectory = fileManager.homeDirectoryForCurrentUser
        let configURL = homeDirectory.appending(path: configRelativePath)
        let workspaceURL = homeDirectory.appending(path: workspaceRelativePath, directoryHint: .isDirectory)
        // Detect through a login shell so PATH updates from the official
        // OpenClaw installer (which writes to ~/.zprofile on macOS) are
        // visible to this GUI app. `/usr/bin/env which` does NOT read
        // the user's shell profile, so without this fix users would see
        // "OpenClaw not detected" right after a successful install.
        let cliPath = loginShellOutput("command -v openclaw").nilIfBlank
        let configExists = fileManager.fileExists(atPath: configURL.path())
        let workspaceExists = fileManager.fileExists(atPath: workspaceURL.path())

        let configPath = "~/.openclaw/openclaw.json"
        let workspacePath = "~/.openclaw/workspace"

        switch (cliPath != nil, configExists, workspaceExists) {
        case (false, _, _):
            return OpenClawInstallStatus(
                readiness: .notInstalled,
                cliPath: nil,
                configPath: configPath,
                workspacePath: workspacePath,
                summary: "The `openclaw` CLI is not on PATH, so the official install has probably not happened on this Mac.",
                recommendation: "Run the official install first: `curl -fsSL https://openclaw.ai/install.sh | bash`, then `openclaw onboard --install-daemon`."
            )
        case (true, false, false):
            return OpenClawInstallStatus(
                readiness: .installedNotOnboarded,
                cliPath: cliPath,
                configPath: configPath,
                workspacePath: workspacePath,
                summary: "The CLI is installed, but the default config and workspace do not exist yet.",
                recommendation: "Finish official onboarding with `openclaw onboard --install-daemon` before applying a custom agent package."
            )
        case (true, true, true):
            return OpenClawInstallStatus(
                readiness: .ready,
                cliPath: cliPath,
                configPath: configPath,
                workspacePath: workspacePath,
                summary: "The CLI, default config, and workspace are all present. The OpenClaw gateway typically listens on localhost:18789 when the daemon is running. This app can safely generate a tuned workspace package to merge in.",
                recommendation: "Use the guided live install for the main workspace, or create an isolated agent workspace with the app and register it through `openclaw agents add`. If the gateway does not respond on port 18789, run `openclaw gateway status`."
            )
        default:
            return OpenClawInstallStatus(
                readiness: .partiallyConfigured,
                cliPath: cliPath,
                configPath: configPath,
                workspacePath: workspacePath,
                summary: "OpenClaw is present, but the default config/workspace footprint is only partially there.",
                recommendation: "Run `openclaw onboard --install-daemon`, then `openclaw gateway status`, then come back here and export the tuned workspace."
            )
        }
#endif
    }

#if !APPSTORE_BUILD
    /// Runs a short command through `/bin/bash -lc` so user-profile
    /// PATH (nvm, fnm, asdf, Homebrew on Apple Silicon, and the
    /// OpenClaw installer's own PATH edits) resolves the same way as
    /// Terminal. Returns empty string on failure. Compiled out in
    /// sandbox.
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
            return String(decoding: data, as: UTF8.self).trimmed
        } catch {
            return ""
        }
    }
#endif
}
