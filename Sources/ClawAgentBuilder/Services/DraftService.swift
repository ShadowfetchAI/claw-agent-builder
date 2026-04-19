import Foundation

/// Errors that bubble up from save/load. We keep these narrow and
/// human-readable so the UI can dump them into an alert verbatim.
enum DraftServiceError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case ioFailed(Error)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Could not encode draft: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Could not read draft file: \(error.localizedDescription)"
        case .ioFailed(let error):
            return "Filesystem error while handling draft: \(error.localizedDescription)"
        }
    }
}

/// Persists `BuilderDraft` values to disk so a user can close the app
/// mid-tune and come back later, or export one draft and keep riffing on
/// another. Drafts live at:
///
///     ~/Library/Application Support/ClawAgentBuilder/drafts/<slug>.json
///
/// We keep the format boring: pretty-printed, sorted-keys JSON so the
/// file is diffable and trivially portable between machines.
enum DraftService {
    private static let folderName = "ClawAgentBuilder"
    private static let draftsSubfolder = "drafts"

    /// Writes the draft to `<slug>.json` under the app-support draft
    /// folder, creating intermediate directories as needed. Returns the
    /// URL we wrote to so the caller can surface it.
    @discardableResult
    static func save(_ draft: BuilderDraft) throws -> URL {
        let folder = try draftsFolderURL()
        let url = folder.appending(path: "\(draft.agentSlug).json")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(draft)
            try data.write(to: url, options: .atomic)
            return url
        } catch let error as EncodingError {
            throw DraftServiceError.encodingFailed(error)
        } catch {
            throw DraftServiceError.ioFailed(error)
        }
    }

    /// Reads a previously saved draft JSON file back into a BuilderDraft.
    static func load(from url: URL) throws -> BuilderDraft {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(BuilderDraft.self, from: data)
        } catch let error as DecodingError {
            throw DraftServiceError.decodingFailed(error)
        } catch {
            throw DraftServiceError.ioFailed(error)
        }
    }

    /// List existing saved drafts, newest-first, so the UI can offer a
    /// "recent" list without any extra bookkeeping.
    static func recentDrafts(limit: Int = 10) -> [URL] {
        guard let folder = try? draftsFolderURL() else { return [] }
        let keys: Set<URLResourceKey> = [.contentModificationDateKey]
        let contents = (try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        )) ?? []

        let sorted = contents
            .filter { $0.pathExtension.lowercased() == "json" }
            .sorted { lhs, rhs in
                let l = (try? lhs.resourceValues(forKeys: keys).contentModificationDate) ?? .distantPast
                let r = (try? rhs.resourceValues(forKeys: keys).contentModificationDate) ?? .distantPast
                return l > r
            }
        return Array(sorted.prefix(limit))
    }

    /// Location of the background autosave file. This is separate from
    /// the named drafts folder so a user's Save-draft list doesn't get
    /// cluttered with the running snapshot we take every few seconds.
    /// If the file exists on launch, the app will offer to restore it.
    static func autosaveURL() throws -> URL {
        let fileManager = FileManager.default
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folder = base.appending(path: folderName, directoryHint: .isDirectory)
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appending(path: "autosave.json")
    }

    /// Write the draft to the autosave slot. Silent — never throws to
    /// the UI, because we don't want a flaky save to interrupt what the
    /// user is doing. Failures print to stderr and we move on.
    static func writeAutosave(_ draft: BuilderDraft) {
        do {
            let url = try autosaveURL()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(draft)
            try data.write(to: url, options: .atomic)
        } catch {
            FileHandle.standardError.write(Data("Autosave failed: \(error.localizedDescription)\n".utf8))
        }
    }

    /// Load the autosaved draft if one exists. Returns nil if nothing
    /// has been autosaved yet or the file is unreadable.
    static func loadAutosaveIfPresent() -> BuilderDraft? {
        guard let url = try? autosaveURL(),
              FileManager.default.fileExists(atPath: url.path()),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(BuilderDraft.self, from: data)
    }

    /// Directory where drafts live. Created on demand.
    static func draftsFolderURL() throws -> URL {
        let fileManager = FileManager.default
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folder = base
            .appending(path: folderName, directoryHint: .isDirectory)
            .appending(path: draftsSubfolder, directoryHint: .isDirectory)
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }
}
