import AppKit
import Foundation
import Observation

/// A small, reusable process runner for the official OpenClaw install
/// flow. The builder app intentionally *does not* reimplement the
/// install — it shells out to the same commands the user would paste
/// into Terminal, so the upstream install stays the source of truth
/// and we never drift.
///
/// Commands we wrap:
///   1. `curl -fsSL https://openclaw.ai/install.sh | bash`  (install CLI)
///   2. `openclaw onboard --install-daemon`                 (onboarding + daemon)
///   3. `openclaw gateway status`                           (verify)
///
/// Everything is streamed live to the UI, including stderr, and we
/// record the exit status so the install card can flip to "ready"
/// automatically after a successful run.
@MainActor
@Observable
final class OpenClawInstaller {
    /// Output buffer for the most recent (or currently running) command.
    /// The UI binds to this for the live console.
    var output: String = ""

    /// Human label for the command currently running. Empty when idle.
    var runningCommandTitle: String = ""

    /// True while a subprocess is in-flight. Disables the Run buttons.
    var isRunning: Bool = false

    /// Exit code of the last finished command, if any.
    var lastExitCode: Int32?

    /// Populated when `runInTerminal` fails — usually because the user
    /// has not granted this app permission to control Terminal in
    /// System Settings → Privacy & Security → Automation. The UI can
    /// observe this and surface a friendly explanation.
    var terminalAutomationError: String?

    private var currentProcess: Process?

    /// The canonical upstream install one-liner. Kept in one place so
    /// the "Run" button, the "Copy command" button, and the
    /// "Run in Terminal" button all agree on what they're promising
    /// to do.
    static let installOneLiner = "curl -fsSL https://openclaw.ai/install.sh | bash"

    static let onboardCommand = "openclaw onboard --install-daemon"
    static let gatewayStatusCommand = "openclaw gateway status"

    nonisolated static func addAgentCommand(slug: String) -> String {
        let cleanedSlug = slugify(slug)
        return "openclaw agents add \(cleanedSlug) --workspace ~/.openclaw/workspace-\(cleanedSlug) --non-interactive"
    }

    /// High-level "steps" we expose in the UI — shortcut for iterating
    /// all of them with consistent labels.
    struct Step: Identifiable {
        let id: String
        let title: String
        let command: String
    }

    static let steps: [Step] = [
        .init(id: "install", title: "1. Install the OpenClaw CLI", command: installOneLiner),
        .init(id: "onboard", title: "2. Run official onboarding", command: onboardCommand),
        .init(id: "status", title: "3. Verify the gateway", command: gatewayStatusCommand)
    ]

    // MARK: - Public runners

    // The App Store edition is sandboxed and cannot spawn arbitrary
    // shells or drive Terminal, so the runners are compiled out. The
    // UI in App Store mode never calls these — it shows copy-only
    // helpers instead, driven by `BuildFlavor.isAppStore`.
#if !APPSTORE_BUILD
    func runInstall() { run(command: Self.installOneLiner, title: "Installing OpenClaw CLI") }
    func runOnboarding() { run(command: Self.onboardCommand, title: "Running onboarding") }
    func runGatewayStatus() { run(command: Self.gatewayStatusCommand, title: "Checking gateway") }
    func runAddIsolatedAgent(slug: String) { run(command: Self.addAgentCommand(slug: slug), title: "Registering isolated agent") }

    /// Cancel the currently running command, if any.
    func cancel() {
        currentProcess?.terminate()
    }
#else
    // Stubs so callers that are hard-wired against the installer still
    // compile. Reaching these means a view forgot its flavor guard —
    // loud but non-fatal.
    func runInstall() { assertionFailure("runInstall called in App Store build") }
    func runOnboarding() { assertionFailure("runOnboarding called in App Store build") }
    func runGatewayStatus() { assertionFailure("runGatewayStatus called in App Store build") }
    func runAddIsolatedAgent(slug: String) { assertionFailure("runAddIsolatedAgent called in App Store build") }
    func cancel() {}
#endif

    /// Put the command on the user's clipboard so they can paste it
    /// into a terminal themselves if they prefer to audit it first.
    func copyToClipboard(_ command: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
    }

    /// Launch Terminal.app and run the command there instead of inside
    /// the app process. This is the safest honest option for commands
    /// that expect a real TTY, especially official onboarding.
    ///
    /// Compiled out in the App Store flavor — sandboxed apps cannot
    /// send Apple Events to Terminal.
#if !APPSTORE_BUILD
    func runInTerminal(_ command: String) {
        let escaped = command.replacingOccurrences(of: "\"", with: "\\\"")
        let script = """
        tell application "Terminal"
            activate
            do script "\(escaped)"
        end tell
        """
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            terminalAutomationError = "Could not build the AppleScript that opens Terminal. Copy the command and run it yourself."
            return
        }
        appleScript.executeAndReturnError(&error)
        if let error {
            // TCC / Automation permission denial surfaces as an NSAppleScript
            // error. Rather than letting the click look like nothing
            // happened, tell the user exactly how to fix it. Error code
            // -1743 is macOS's "not allowed to send Apple events" code.
            let code = (error["NSAppleScriptErrorNumber"] as? Int) ?? 0
            let message = (error["NSAppleScriptErrorMessage"] as? String) ?? "Unknown AppleScript error."
            if code == -1743 {
                terminalAutomationError = "macOS blocked this app from controlling Terminal. Open System Settings → Privacy & Security → Automation, find this app, and enable Terminal. Or just copy the command and paste it into Terminal yourself."
            } else {
                terminalAutomationError = "Could not open Terminal automatically (\(message)). Copy the command and run it yourself — the result is identical."
            }
        } else {
            terminalAutomationError = nil
        }
    }
#else
    func runInTerminal(_ command: String) {
        // In App Store mode we can't drive Terminal — copy to clipboard
        // and let the user paste it themselves. Views gate this so the
        // call is never made, but keeping a safe stub prevents link
        // errors if a call site slips through.
        copyToClipboard(command)
    }
#endif

    // MARK: - Process plumbing

#if !APPSTORE_BUILD
    /// Runs a shell command inside a login bash so PATH and brew-managed
    /// tools (like `openclaw` after install) resolve the same way they
    /// would in Terminal. Streams stdout and stderr line-by-line into
    /// `output` on the main actor. Compiled out in sandbox.
    private func run(command: String, title: String) {
        guard !isRunning else { return }

        isRunning = true
        runningCommandTitle = title
        lastExitCode = nil
        output = "$ \(command)\n"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-lc", command]

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        let appendChunk: @Sendable (Data) -> Void = { [weak self] data in
            guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8) else { return }
            Task { @MainActor in
                self?.output += chunk
            }
        }

        outPipe.fileHandleForReading.readabilityHandler = { handle in
            appendChunk(handle.availableData)
        }
        errPipe.fileHandleForReading.readabilityHandler = { handle in
            appendChunk(handle.availableData)
        }

        process.terminationHandler = { [weak self] finished in
            // Drain anything left in the pipes before we report done,
            // otherwise the tail of a fast install can get swallowed.
            let remainingOut = outPipe.fileHandleForReading.readDataToEndOfFile()
            let remainingErr = errPipe.fileHandleForReading.readDataToEndOfFile()
            appendChunk(remainingOut)
            appendChunk(remainingErr)

            outPipe.fileHandleForReading.readabilityHandler = nil
            errPipe.fileHandleForReading.readabilityHandler = nil

            let code = finished.terminationStatus
            Task { @MainActor in
                self?.output += "\n[process exited with status \(code)]\n"
                self?.lastExitCode = code
                self?.isRunning = false
                self?.runningCommandTitle = ""
                self?.currentProcess = nil
            }
        }

        do {
            try process.run()
            currentProcess = process
        } catch {
            output += "\n[failed to launch: \(error.localizedDescription)]\n"
            isRunning = false
            runningCommandTitle = ""
        }
    }
#endif
}
