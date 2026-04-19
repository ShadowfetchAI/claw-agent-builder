import Foundation

/// Runtime hook for which build flavor we're running as.
///
/// The codebase produces two products from one source tree:
///
///   • **Developer ID** (default) — ships from GitHub. Full automation:
///     spawns `Process` to run shell commands, uses `NSAppleScript` to
///     open Terminal, detects Node / Homebrew / OpenClaw on PATH, and
///     writes directly into `~/.openclaw/workspace`.
///
///   • **App Store** — compiled with `-DAPPSTORE_BUILD`. Sandboxed,
///     notarized, distributed through Mac App Store. The install
///     wizard and all shell/AppleScript surfaces are compiled out. The
///     app becomes a workspace-file generator + API-key sanity checker
///     that writes into a folder the user picks via NSOpenPanel.
///
/// Views and services consult this flavor so gated features either
/// degrade gracefully or are skipped entirely in sandboxed builds.
enum BuildFlavor: String {
    case developerID
    case appStore

    static let current: BuildFlavor = {
        #if APPSTORE_BUILD
        return .appStore
        #else
        return .developerID
        #endif
    }()

    static var isAppStore: Bool { current == .appStore }
    static var isDeveloperID: Bool { current == .developerID }

    /// Human label for the footer / About screen.
    var displayName: String {
        switch self {
        case .developerID: return "Developer ID edition"
        case .appStore: return "App Store edition"
        }
    }
}
