import Foundation
import Testing
@testable import ClawAgentBuilder

@Test func generatedFilesIncludeOpenClawWorkspaceCore() async throws {
    let files = TemplateRenderer.generatedFiles(for: BuilderDraft(), installStatus: .unknown)
    let paths = Set(files.map(\.path))

    #expect(paths.contains("AGENTS.md"))
    #expect(paths.contains("SOUL.md"))
    #expect(paths.contains("USER.md"))
    #expect(paths.contains("HEARTBEAT.md"))
    #expect(paths.contains("FOUNDER_PROFILE.md"))
    #expect(paths.contains("INSTALL_GUIDE.md"))
    #expect(paths.contains("openclaw.config.patch.json"))
    #expect(!paths.contains("openclaw.json.example"))
}

@Test func installGuideUsesOfficialInstallFlow() async throws {
    let guide = TemplateRenderer.generatedFiles(for: BuilderDraft(), installStatus: .unknown)
        .first(where: { $0.path == "INSTALL_GUIDE.md" })?
        .contents ?? ""

    #expect(guide.contains("curl -fsSL https://openclaw.ai/install.sh | bash"))
    #expect(guide.contains("openclaw onboard --install-daemon"))
    #expect(guide.contains("openclaw gateway status"))
    #expect(guide.contains("openclaw dashboard"))
}

@Test func isolatedInstallUsesWorkspaceDashSlugPath() async throws {
    let destination = try WorkspaceInstaller.resolveDestination(
        for: .isolatedAgent(slug: "atlas"),
        fileManager: .default
    )

    let normalizedPath = destination.path().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    #expect(normalizedPath.hasSuffix(".openclaw/workspace-atlas"))
}

@Test func addAgentCommandUsesOfficialWorkspaceFlag() async throws {
    let command = OpenClawInstaller.addAgentCommand(slug: "atlas")

    #expect(command == "openclaw agents add atlas --workspace ~/.openclaw/workspace-atlas --non-interactive")
}
