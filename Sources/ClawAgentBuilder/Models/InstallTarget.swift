import Foundation

/// Where a generated CLAW Agent package will actually land on disk.
///
/// The builder used to only ever export a folder to the Desktop. For the
/// majority of users that meant "build a package and then manually copy the
/// files into ``~/.openclaw/workspace``" — fiddly and error-prone.
///
/// `InstallTarget` lets the user pick exactly where the package should go:
/// either into their real OpenClaw workspace (replacing the default agent),
/// into a sibling workspace folder for a new isolated agent, into a plain
/// Desktop package for inspection, or into any custom folder they choose.
///
/// The target is also responsible for describing itself in human copy so
/// PreviewAndExport can show a clear "this is what will happen" preview.
enum InstallTarget: Hashable, Identifiable {
    /// Install directly into `~/.openclaw/workspace` — the default agent.
    case liveMainWorkspace

    /// Install into `~/.openclaw/workspace-<slug>` — the default
    /// workspace path OpenClaw docs use for isolated agents created with
    /// `openclaw agents add <name> --workspace ~/.openclaw/workspace-<name>`.
    case isolatedAgent(slug: String)

    /// Write a timestamped preview folder to `~/Desktop/CLAW Agent …/`.
    case desktopPackage

    /// Write to a folder the user explicitly picks (e.g. a remote share,
    /// an external drive, or a staging area before a remote sync).
    case customFolder(url: URL)

    var id: String {
        switch self {
        case .liveMainWorkspace:
            return "live"
        case .isolatedAgent(let slug):
            return "isolated-\(slug)"
        case .desktopPackage:
            return "desktop"
        case .customFolder(let url):
            return "custom-\(url.path())"
        }
    }

    var shortTitle: String {
        switch self {
        case .liveMainWorkspace:
            return "Install into ~/.openclaw/workspace"
        case .isolatedAgent(let slug):
            return "Isolated workspace: ~/.openclaw/workspace-\(slug)"
        case .desktopPackage:
            return "Export preview to Desktop"
        case .customFolder(let url):
            return "Custom folder: \(url.lastPathComponent)"
        }
    }

    var explanation: String {
        switch self {
        case .liveMainWorkspace:
            return "Writes the full workspace file pack directly into your real OpenClaw default agent. Existing files are backed up first, so this is reversible."
        case .isolatedAgent(let slug):
            return "Writes a brand-new isolated workspace at ~/.openclaw/workspace-\(slug). To fully register it as an OpenClaw agent, run `openclaw agents add \(slug) --workspace ~/.openclaw/workspace-\(slug) --non-interactive`."
        case .desktopPackage:
            return "Writes a fresh, timestamped folder to your Desktop so you can inspect every file before copying anything into OpenClaw."
        case .customFolder(let url):
            return "Writes the pack into \(url.path()). Useful for remote gateways, staging areas, or external drives."
        }
    }

    var isLive: Bool {
        if case .liveMainWorkspace = self { return true }
        return false
    }

    /// Whether writing to this target would overwrite an existing
    /// OpenClaw workspace. Callers use this to decide whether to offer
    /// a backup-first flow.
    var mayOverwriteExisting: Bool {
        switch self {
        case .liveMainWorkspace, .isolatedAgent, .customFolder:
            return true
        case .desktopPackage:
            return false
        }
    }
}
