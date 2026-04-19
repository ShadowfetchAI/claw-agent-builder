import Foundation

/// Result returned to the UI after a successful install. We show the
/// folder we wrote to, how many files landed, and — if we backed up an
/// existing workspace on the way in — where those backups went, so the
/// user can always roll back by hand.
struct InstallReport {
    let target: InstallTarget
    let destinationURL: URL
    let writtenFileCount: Int
    let backupURL: URL?

    var wasLiveInstall: Bool { target.isLive }
}

enum WorkspaceInstallError: LocalizedError {
    case targetUnresolvable(String)
    case destinationIsFile(URL)

    var errorDescription: String? {
        switch self {
        case .targetUnresolvable(let reason):
            return "Could not resolve install target: \(reason)"
        case .destinationIsFile(let url):
            return "Expected a folder at \(url.path()), but a file is there. Move it aside and try again."
        }
    }
}

/// The real installer behind every "Install" / "Export" action in the
/// builder. It converts an `InstallTarget` into a concrete destination
/// URL, optionally backs up whatever is already there, then writes the
/// full file pack produced by `TemplateRenderer` plus bundled assets and
/// a config patch file for manual merge review.
///
/// Design choices:
/// - **Backups are silent + automatic for live-style targets.** People
///   tuning their main agent should never lose existing customizations;
///   we move the old workspace to `…-claw-backup-<timestamp>/` before we
///   write. The report surfaces the backup URL so the UI can point to it.
/// - **Desktop preview never backs up.** It always writes a new unique
///   folder — inspection is the whole point.
/// - **Per-file writes create intermediate directories.** Some files
///   live in subfolders (`memory/`, `skills/`, `avatars/`). The installer
///   makes sure those exist before writing.
enum WorkspaceInstaller {
    static func install(
        draft: BuilderDraft,
        installStatus: OpenClawInstallStatus,
        target: InstallTarget
    ) throws -> InstallReport {
        let fileManager = FileManager.default
        let destinationURL = try resolveDestination(for: target, fileManager: fileManager)

        // Back up an existing workspace if we're writing into a location
        // that already has content. We intentionally do this AFTER
        // resolving the destination (so relative-path bugs don't ever
        // accidentally back up something unrelated).
        var backupURL: URL?
        if target.mayOverwriteExisting,
           fileManager.fileExists(atPath: destinationURL.path()),
           directoryHasContents(at: destinationURL, fileManager: fileManager) {
            backupURL = try backupExisting(destination: destinationURL, fileManager: fileManager)
        }

        try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)

        var writtenCount = 0
        for file in TemplateRenderer.generatedFiles(for: draft, installStatus: installStatus) {
            let fileURL = destinationURL.appending(path: file.path)
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try file.contents.write(to: fileURL, atomically: true, encoding: .utf8)
            writtenCount += 1
        }

        writtenCount += try writeBundledAssets(
            draft: draft,
            destination: destinationURL,
            fileManager: fileManager
        )

        try writeBuilderProfile(
            draft: draft,
            destination: destinationURL,
            fileManager: fileManager
        )
        writtenCount += 1

        return InstallReport(
            target: target,
            destinationURL: destinationURL,
            writtenFileCount: writtenCount,
            backupURL: backupURL
        )
    }

    // MARK: - Target resolution

    static func resolveDestination(for target: InstallTarget, fileManager: FileManager) throws -> URL {
        let home = fileManager.homeDirectoryForCurrentUser

        switch target {
        case .liveMainWorkspace:
            return home.appending(path: ".openclaw/workspace", directoryHint: .isDirectory)

        case .isolatedAgent(let slug):
            let cleanedSlug = slug.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanedSlug.isEmpty else {
                throw WorkspaceInstallError.targetUnresolvable("isolated agent slug was empty")
            }
            return home.appending(path: ".openclaw/workspace-\(cleanedSlug)", directoryHint: .isDirectory)

        case .desktopPackage:
            let desktop = home.appending(path: "Desktop", directoryHint: .isDirectory)
            let timestamp = exportTimestamp()
            // Slug is pulled from the draft elsewhere; keep the timestamp-unique folder to avoid accidental overwrite.
            return desktop.appending(path: "CLAW Agent Preview - \(timestamp)", directoryHint: .isDirectory)

        case .customFolder(let url):
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path(), isDirectory: &isDirectory), !isDirectory.boolValue {
                throw WorkspaceInstallError.destinationIsFile(url)
            }
            return url
        }
    }

    // MARK: - Backups

    private static func backupExisting(destination: URL, fileManager: FileManager) throws -> URL {
        let timestamp = exportTimestamp()
        let parent = destination.deletingLastPathComponent()
        let backupName = "\(destination.lastPathComponent)-claw-backup-\(timestamp)"
        let backupURL = parent.appending(path: backupName, directoryHint: .isDirectory)

        // moveItem is atomic and preserves timestamps; if it fails for
        // some FS-level reason (cross-device, permission), surface the
        // error rather than silently stepping on the user's files.
        try fileManager.moveItem(at: destination, to: backupURL)
        return backupURL
    }

    private static func directoryHasContents(at url: URL, fileManager: FileManager) -> Bool {
        let contents = (try? fileManager.contentsOfDirectory(atPath: url.path())) ?? []
        return !contents.isEmpty
    }

    // MARK: - Asset writing

    private static func writeBundledAssets(
        draft: BuilderDraft,
        destination: URL,
        fileManager: FileManager
    ) throws -> Int {
        var writtenCount = 0

        // The full question bank is only relevant when daily questions
        // are turned on — otherwise we'd ship ~1 MB of unused text.
        if draft.enableDailyQuestions,
           draft.includeQuestionBank,
           let questionData = bundledData(named: "1000_get_to_know_someone_questions", extension: "txt") {
            let url = destination.appending(path: "data/personality-questions.txt")
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try questionData.write(to: url)
            writtenCount += 1
        }

        // A default avatar so the agent has something on disk that maps
        // to IDENTITY.md's `Avatar: avatars/agent.png` line.
        if let iconData = bundledData(named: "app-icon", extension: "png") {
            let url = destination.appending(path: "avatars/agent.png")
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try iconData.write(to: url)
            writtenCount += 1
        }

        // Nice-to-have for "getting to know you" flows — ships an image
        // the agent can reference when opening the rapport skill.
        if let introData = bundledData(named: "getting-to-know-you", extension: "jpg") {
            let url = destination.appending(path: "avatars/getting-to-know-you.jpg")
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try introData.write(to: url)
            writtenCount += 1
        }

        return writtenCount
    }

    private static func writeBuilderProfile(
        draft: BuilderDraft,
        destination: URL,
        fileManager: FileManager
    ) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let profileData = try encoder.encode(draft)

        // `.claw-builder/` is a hidden sibling folder so it doesn't
        // clutter workspace listings; the file lets the builder reload
        // this draft later for retuning.
        let url = destination.appending(path: ".claw-builder/builder-profile.json")
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try profileData.write(to: url)
    }

    private static func bundledData(named name: String, extension fileExtension: String) -> Data? {
        guard let url = Bundle.module.url(forResource: name, withExtension: fileExtension) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    private static func exportTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter.string(from: Date())
    }
}
