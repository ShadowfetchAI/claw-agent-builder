import Foundation

struct ExportResult {
    let folderURL: URL
    let writtenFileCount: Int
}

enum ExportService {
    static func export(draft: BuilderDraft, installStatus: OpenClawInstallStatus) throws -> ExportResult {
        let fileManager = FileManager.default
        let desktopURL = fileManager.homeDirectoryForCurrentUser.appending(path: "Desktop", directoryHint: .isDirectory)
        let timestamp = exportTimestamp()
        let folderName = "CLAW Agent Build - \(draft.agentSlug)-\(timestamp)"
        let rootURL = desktopURL.appending(path: folderName, directoryHint: .isDirectory)

        try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)

        var writtenFileCount = 0
        let generatedFiles = TemplateRenderer.generatedFiles(for: draft, installStatus: installStatus)

        for generatedFile in generatedFiles {
            let fileURL = rootURL.appending(path: generatedFile.path)
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try generatedFile.contents.write(to: fileURL, atomically: true, encoding: .utf8)
            writtenFileCount += 1
        }

        if draft.enableDailyQuestions,
           draft.includeQuestionBank,
           let questionData = bundledData(named: "1000_get_to_know_someone_questions", extension: "txt") {
            let questionURL = rootURL.appending(path: "data/personality-questions.txt")
            try fileManager.createDirectory(at: questionURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try questionData.write(to: questionURL)
            writtenFileCount += 1
        }

        if let iconData = bundledData(named: "app-icon", extension: "png") {
            let iconURL = rootURL.appending(path: "assets/app-icon.png")
            try fileManager.createDirectory(at: iconURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try iconData.write(to: iconURL)
            writtenFileCount += 1
        }

        if let introImageData = bundledData(named: "getting-to-know-you", extension: "jpg") {
            let imageURL = rootURL.appending(path: "assets/getting-to-know-you.jpg")
            try fileManager.createDirectory(at: imageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try introImageData.write(to: imageURL)
            writtenFileCount += 1
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let profileData = try encoder.encode(draft)
        try profileData.write(to: rootURL.appending(path: "builder-profile.json"))
        writtenFileCount += 1

        return ExportResult(folderURL: rootURL, writtenFileCount: writtenFileCount)
    }

    private static func exportTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter.string(from: Date())
    }

    private static func bundledData(named name: String, extension fileExtension: String) -> Data? {
        guard let url = Bundle.module.url(forResource: name, withExtension: fileExtension) else {
            return nil
        }

        return try? Data(contentsOf: url)
    }
}

