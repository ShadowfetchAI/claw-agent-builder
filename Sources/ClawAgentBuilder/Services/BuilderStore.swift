import AppKit
import Observation
import SwiftUI

@MainActor
@Observable
final class BuilderStore {
    var draft = BuilderDraft()
    var selectedSection: BuilderSection = .welcome
    var selectedPreviewPath: String = "AGENTS.md"
    var installStatus: OpenClawInstallStatus = .unknown
    var alertTitle: String = ""
    var alertMessage: String = ""
    var showingAlert = false
    var lastExportURL: URL?
    var lastInstallReport: InstallReport?

    /// Shared runner for the official OpenClaw install commands. Lives
    /// on the store so every screen can observe the same live output.
    let openClawInstaller = OpenClawInstaller()

    /// Shared live-key validator behind the "Test" button on each
    /// provider card. Kept on the store so every screen observing the
    /// API keys section sees the same per-provider status.
    let providerKeyTester = ProviderKeyTester()

    /// Detects whether Node.js (>= 22.14 or 24.x) and Homebrew are
    /// available. Surfaced at the top of the install page so newbies
    /// fix prerequisites before the guided setup errors out.
    let prereqChecker = SystemPrereqChecker()

    /// Holds the pre-preset draft so the user can undo the most recent
    /// preset application. Cleared after a real save or another preset.
    private var presetUndoSnapshot: BuilderDraft?

    /// Whether the UI should offer an "Undo preset" affordance.
    var canUndoPreset: Bool { presetUndoSnapshot != nil }

    /// Progress log for the guided setup flow so the UI can show a
    /// readable timeline separate from raw shell output.
    var guidedSetupLog: [String] = []
    var guidedSetupIsRunning: Bool = false

    /// Which flow the user picked on the Welcome page. `nil` means they
    /// haven't picked yet — the Welcome page shows the choice prominently
    /// so first-timers don't feel dropped into the middle of a wizard.
    var startingPath: StartingPath?

    /// The user's chosen install destination. Defaults to a Desktop
    /// preview so the very first click never overwrites a real workspace
    /// — you have to opt into live installs.
    var selectedInstallTarget: InstallTarget = .desktopPackage

    /// Custom folder the user picked via NSOpenPanel, kept separately so
    /// toggling back and forth between Desktop and Custom remembers the
    /// last location.
    var customFolderURL: URL?

    private var isInternallyUpdatingSection = false

    /// Time of the most recent autosave write, shown in the footer so
    /// users can visibly trust that their work is not evaporating.
    var lastAutosaveAt: Date?

    /// Set once `startAutosave()` has been called so we don't spin up
    /// more than one autosave loop per store.
    private var autosaveTask: Task<Void, Never>?

    /// Hash of the last autosaved draft. We compare on each tick so the
    /// loop skips disk writes (and UI "saved at" updates) when nothing
    /// actually changed — keeps SSDs and scroll views calm.
    private var lastAutosaveSignature: Int?

    var generatedFiles: [GeneratedFile] {
        TemplateRenderer.generatedFiles(for: draft, installStatus: installStatus)
    }

    /// Basic guardrail the UI can check before letting the user install
    /// into a live workspace. We don't block Desktop preview — that's
    /// meant to work even with a half-finished draft.
    var canInstallToLiveTarget: Bool {
        !draft.agentSlug.isEmpty
            && !draft.agentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init() {
        ensurePreviewSelection()
    }

    // MARK: - Autosave

    /// Kick off the background autosave loop. Safe to call multiple
    /// times — subsequent calls are no-ops. We snapshot the draft to
    /// `autosave.json` every few seconds so a first-time user who
    /// closes the app mid-tuning never loses work.
    func startAutosave() {
        guard autosaveTask == nil else { return }
        autosaveTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 8_000_000_000)
                guard let self else { return }
                await MainActor.run {
                    let snapshot = self.draft
                    // Cheap dirty check: encode once and compare the
                    // bytes. Skipping unchanged ticks avoids touching
                    // disk and keeps the "saved at" timestamp stable so
                    // the footer doesn't flicker when the user is idle.
                    guard let data = try? JSONEncoder().encode(snapshot) else { return }
                    let signature = data.hashValue
                    if signature == self.lastAutosaveSignature { return }
                    self.lastAutosaveSignature = signature
                    DraftService.writeAutosave(snapshot)
                    self.lastAutosaveAt = Date()
                }
            }
        }
    }

    /// Write the current draft to the autosave slot immediately — used
    /// when the app is going to the background or quitting, and after
    /// big state changes like applying a preset.
    func flushAutosave() {
        DraftService.writeAutosave(draft)
        if let data = try? JSONEncoder().encode(draft) {
            lastAutosaveSignature = data.hashValue
        }
        lastAutosaveAt = Date()
    }

    /// If the app was interrupted previously and left behind an
    /// autosave snapshot, restore it. We only do this when the current
    /// draft is still fresh-out-of-init so we never stomp on real work.
    func restoreAutosaveIfAvailable() {
        guard let restored = DraftService.loadAutosaveIfPresent() else { return }
        draft = restored
        ensurePreviewSelection()
    }

    func sectionCompletion(_ section: BuilderSection) -> SectionCompletion {
        switch section {
        case .welcome:
            return .done
        case .openClawInstall:
            // App Store edition hides this section entirely — if it
            // somehow gets queried, treat it as done so navigation is
            // never blocked.
            if BuildFlavor.isAppStore { return .done }
            // When the user asserts on the Welcome page that they
            // already have OpenClaw, treat this section as done so the
            // rest of the wizard unlocks — even if our detection can't
            // see the CLI (e.g. installed via a PATH this app doesn't
            // see, or running in an unusual environment). Trusting the
            // user here is better than blocking them.
            if startingPath == .existingOpenClaw {
                return .done
            }
            switch installStatus.readiness {
            case .ready:
                return .done
            case .installedNotOnboarded, .partiallyConfigured:
                return .inProgress
            case .notInstalled:
                return .notStarted
            }
        case .identity:
            let hasAgentName = !draft.agentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasFounderName = !draft.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if !hasAgentName && !hasFounderName { return .notStarted }
            return hasAgentName && hasFounderName ? .done : .inProgress
        case .focus:
            return draft.selectedJobs.isEmpty ? .notStarted : .done
        case .founderFile:
            if !draft.useFounderProfileInjection { return .done }
            let answered = draft.answeredFounderQuestionsCount
            if answered == 0 { return .notStarted }
            return .done
        case .toolsAndBridges:
            return draft.selectedChannels.isEmpty && draft.selectedBridges.isEmpty ? .notStarted : .done
        case .dailyQuestions:
            return .done
        case .dataSources:
            return draft.selectedAPIs.isEmpty ? .notStarted : .done
        case .apiKeys:
            let hasEnabledProvider = !draft.enabledProviderIDs.isEmpty
            let hasRealProviderKey = ModelProviderCatalog.all.contains { provider in
                draft.enabledProviderIDs.contains(provider.id)
                    && (draft.apiKeyValues[provider.envKey]?.nilIfBlank != nil)
            }
            if !hasEnabledProvider { return .notStarted }
            return hasRealProviderKey ? .done : .inProgress
        case .preview:
            return allRequiredSectionsComplete ? .done : .inProgress
        }
    }

    var allRequiredSectionsComplete: Bool {
        BuilderSection.visibleCases
            .filter { $0 != .preview }
            .allSatisfy { sectionCompletion($0) == .done }
    }

    func isSectionUnlocked(_ section: BuilderSection) -> Bool {
        for earlier in BuilderSection.visibleCases {
            if earlier == section { return true }
            if sectionCompletion(earlier) != .done {
                return false
            }
        }
        return true
    }

    func goToSection(_ section: BuilderSection) {
        guard isSectionUnlocked(section) else {
            showStepLockedAlert(for: section)
            return
        }
        setSection(section)
    }

    /// Commits the user's Welcome-page choice and routes them to the
    /// right next section. "Existing OpenClaw" users skip the install
    /// page and go straight to Identity — the builder just replaces
    /// their workspace files. "Full install" users land on the install
    /// page for the guided CLI setup.
    func chooseStartingPath(_ path: StartingPath) {
        startingPath = path
        switch path {
        case .existingOpenClaw:
            // User already has OpenClaw — default them to the live
            // workspace target so the export step just drops files into
            // their existing ~/.openclaw/workspace (with automatic
            // backup of whatever was there).
            selectedInstallTarget = .liveMainWorkspace
            setSection(.identity)
        case .fullInstall:
            selectedInstallTarget = .liveMainWorkspace
            setSection(.openClawInstall)
        }
        flushAutosave()
    }

    func moveToNextSection() {
        guard let next = selectedSection.next else { return }
        guard sectionCompletion(selectedSection) == .done else {
            showCurrentStepIncompleteAlert()
            return
        }
        setSection(next)
    }

    func moveToPreviousSection() {
        guard let previous = selectedSection.previous else { return }
        setSection(previous)
    }

    func refreshInstallStatus() {
        installStatus = OpenClawInstallChecker.detect()
        prereqChecker.refresh()
        ensurePreviewSelection()
    }

    func founderAnswerBinding(for question: FounderQuestion) -> Binding<String> {
        Binding(
            get: { self.draft.founderAnswers[question.number] ?? "" },
            set: { self.draft.founderAnswers[question.number] = $0 }
        )
    }

    func containsSecondaryFocus(_ focus: FocusPack) -> Bool {
        draft.secondaryFocuses.contains(focus)
    }

    func setSecondaryFocus(_ focus: FocusPack, enabled: Bool) {
        if enabled {
            draft.secondaryFocuses.insert(focus)
        } else {
            draft.secondaryFocuses.remove(focus)
        }
    }

    func containsJob(_ job: JobOption) -> Bool {
        draft.selectedJobs.contains(job)
    }

    func setJob(_ job: JobOption, enabled: Bool) {
        if enabled {
            draft.selectedJobs.insert(job)
        } else {
            draft.selectedJobs.remove(job)
        }
    }

    func containsChannel(_ channel: ChannelOption) -> Bool {
        draft.selectedChannels.contains(channel)
    }

    func setChannel(_ channel: ChannelOption, enabled: Bool) {
        if enabled {
            draft.selectedChannels.insert(channel)
        } else {
            draft.selectedChannels.remove(channel)
        }
    }

    func containsBridge(_ bridge: BridgePack) -> Bool {
        draft.selectedBridges.contains(bridge)
    }

    func setBridge(_ bridge: BridgePack, enabled: Bool) {
        if enabled {
            draft.selectedBridges.insert(bridge)
        } else {
            draft.selectedBridges.remove(bridge)
        }
    }

    func containsAPI(_ api: ApiCatalogItem) -> Bool {
        draft.selectedAPIs.contains(api)
    }

    func setAPI(_ api: ApiCatalogItem, enabled: Bool) {
        if enabled {
            draft.selectedAPIs.insert(api)
        } else {
            draft.selectedAPIs.remove(api)
        }
    }

    func summaryIncludesSection(_ section: FounderQuestionSection) -> Bool {
        draft.summaryEnabledSections.contains(section)
    }

    func setSummarySection(_ section: FounderQuestionSection, enabled: Bool) {
        if enabled {
            draft.summaryEnabledSections.insert(section)
        } else {
            draft.summaryEnabledSections.remove(section)
        }
    }

    func applyPrimaryFocusRecommendations() {
        for recommendation in draft.primaryFocus.recommendedJobs {
            draft.selectedJobs.insert(recommendation)
        }
    }

    // MARK: - Install / Export

    /// Legacy Desktop-only export kept for the old button label. New
    /// code should prefer `install(to:)` with an explicit target.
    func exportToDesktop() {
        install(to: .desktopPackage)
    }

    /// Resolves the currently selected target (which may reference the
    /// draft's slug or a user-chosen custom folder) into the concrete
    /// `InstallTarget` the installer understands.
    func resolvedSelectedTarget() -> InstallTarget {
        switch selectedInstallTarget {
        case .isolatedAgent:
            return .isolatedAgent(slug: draft.agentSlug)
        case .customFolder:
            if let customFolderURL {
                return .customFolder(url: customFolderURL)
            }
            return .desktopPackage
        default:
            return selectedInstallTarget
        }
    }

    /// Single entry point used by every install/export button in the
    /// app. Resolves the target, runs the installer, and reports the
    /// outcome via the shared alert.
    func install(to target: InstallTarget) {
        if target.isLive || target.mayOverwriteExisting {
            guard canInstallToLiveTarget else {
                alertTitle = "Can't install yet"
                alertMessage = "Give the agent a name before installing into a real workspace."
                showingAlert = true
                return
            }
        }

        do {
            let report = try WorkspaceInstaller.install(
                draft: draft,
                installStatus: installStatus,
                target: target
            )
            lastInstallReport = report
            lastExportURL = report.destinationURL
            alertTitle = target.isLive ? "Installed into OpenClaw" : "Package written"
            var message = "Wrote \(report.writtenFileCount) files to \(report.destinationURL.path())."
            if let backupURL = report.backupURL {
                message += "\n\nBackup of previous workspace: \(backupURL.path())"
            }
            alertMessage = message
            showingAlert = true
            NSWorkspace.shared.activateFileViewerSelecting([report.destinationURL])
        } catch {
            alertTitle = "Install Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }

    // MARK: - Drafts

    func saveDraft() {
        do {
            let url = try DraftService.save(draft)
            alertTitle = "Draft saved"
            alertMessage = "Saved to \(url.path())"
            showingAlert = true
        } catch {
            alertTitle = "Save Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }

    func loadDraft(from url: URL) {
        do {
            let loaded = try DraftService.load(from: url)
            draft = loaded
            ensurePreviewSelection()
            alertTitle = "Draft loaded"
            alertMessage = "Loaded from \(url.lastPathComponent)"
            showingAlert = true
        } catch {
            alertTitle = "Load Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }

    func recentDrafts() -> [URL] {
        DraftService.recentDrafts()
    }

    // MARK: - Presets

    /// Applies the preset on top of a freshly-initialized draft so we
    /// never get mystery leftover state from whatever the user was
    /// editing before. Founder answers are *preserved* because those
    /// are personal content the preset has no business overwriting.
    func applyPreset(_ preset: AgentPreset) {
        // Snapshot the pre-preset draft so the user has a reliable
        // one-click escape if the preset wasn't what they expected.
        presetUndoSnapshot = draft

        let preservedAnswers = draft.founderAnswers
        var fresh = BuilderDraft()
        preset.apply(&fresh)
        fresh.founderAnswers = preservedAnswers
        draft = fresh
        ensurePreviewSelection()
        flushAutosave()
    }

    /// Roll the draft back to whatever it was before the most recent
    /// preset application. Safe no-op when nothing to undo.
    func undoPreset() {
        guard let snapshot = presetUndoSnapshot else { return }
        draft = snapshot
        presetUndoSnapshot = nil
        ensurePreviewSelection()
        flushAutosave()
    }

    private func setSection(_ section: BuilderSection) {
        guard !isInternallyUpdatingSection else { return }
        isInternallyUpdatingSection = true
        selectedSection = section
        isInternallyUpdatingSection = false
    }

    private func showStepLockedAlert(for requestedSection: BuilderSection) {
        let blockingStep = BuilderSection.allCases.first { section in
            section.stepNumber < requestedSection.stepNumber && sectionCompletion(section) != .done
        } ?? selectedSection

        alertTitle = "Finish the current flow first"
        alertMessage = "This wizard is locked step by step. Complete \"\(blockingStep.title)\" before moving to \"\(requestedSection.title)\"."
        showingAlert = true
    }

    private func showCurrentStepIncompleteAlert() {
        alertTitle = "Finish this step first"
        alertMessage = "Complete \"\(selectedSection.title)\" before moving on to the next page."
        showingAlert = true
    }

    // MARK: - Guided setup (install OpenClaw + build the tuned agent)

    /// Beginner-friendly flow that handles what can be automated safely:
    /// install the CLI when missing, route interactive onboarding to a
    /// real Terminal window when needed, optionally register an isolated
    /// agent, then write the tuned workspace.
    ///
    /// Step 1 is skipped when the CLI is already on PATH.
    func runGuidedSetup(target: InstallTarget) {
        guard !guidedSetupIsRunning else { return }

        // Live workspace installs need a named agent. Desktop preview
        // works even with a blank slate.
        if target.mayOverwriteExisting && !canInstallToLiveTarget {
            alertTitle = "Can't run guided setup yet"
            alertMessage = "Give the agent a name in Identity before installing into a real workspace."
            showingAlert = true
            return
        }

        guidedSetupIsRunning = true
        guidedSetupLog = []

        Task { @MainActor in
            defer {
                guidedSetupIsRunning = false
                refreshInstallStatus()
            }

            // Pre-flight: make sure Node is present before we spawn the
            // official installer. Catching this here means the user gets
            // a readable "install Node" nudge instead of a raw shell
            // error from somewhere inside the OpenClaw install script.
            prereqChecker.refresh()
            try? await Task.sleep(nanoseconds: 400_000_000)
            switch prereqChecker.node.state {
            case .ok:
                break
            case .missing:
                guidedSetupLog.append("✗ Node.js isn't installed yet. OpenClaw needs Node 22.14+ or 24.x. Install Node first (the Prerequisites card above has a one-click button), then come back and try again.")
                return
            case .tooOld(let found, let minimum):
                guidedSetupLog.append("✗ Node.js \(found) is older than \(minimum). OpenClaw won't run on this version — upgrade Node (Prerequisites card above), then re-run guided setup.")
                return
            }

            let cliAlreadyPresent = OpenClawInstallChecker.detect().cliPath != nil
            if cliAlreadyPresent {
                guidedSetupLog.append("• OpenClaw CLI already installed — skipping install step.")
            } else {
                guidedSetupLog.append("• Installing OpenClaw CLI…")
                await runAndWait { self.openClawInstaller.runInstall() }
                if openClawInstaller.lastExitCode != 0 {
                    guidedSetupLog.append("✗ Install failed — stopping.")
                    return
                }
                guidedSetupLog.append("✓ OpenClaw CLI installed.")
            }

            let configURL = FileManager.default.homeDirectoryForCurrentUser
                .appending(path: ".openclaw/openclaw.json")
            if FileManager.default.fileExists(atPath: configURL.path()) {
                guidedSetupLog.append("• Found existing ~/.openclaw/openclaw.json — skipping onboarding so your config isn't overwritten.")
            } else {
                guidedSetupLog.append("• Official onboarding needs a real Terminal session. Opening Terminal for the official `openclaw onboard --install-daemon` flow…")
                openClawInstaller.runInTerminal(OpenClawInstaller.onboardCommand)
                guidedSetupLog.append("• Finish the prompts in Terminal, then come back and click the guided setup button again.")
                return
            }

            if case .isolatedAgent(let slug) = target {
                guidedSetupLog.append("• Registering isolated agent `\(slug)` with the official OpenClaw CLI…")
                await runAndWait { self.openClawInstaller.runAddIsolatedAgent(slug: slug) }
                if openClawInstaller.lastExitCode != 0 {
                    guidedSetupLog.append("✗ Could not register the isolated agent. Check the log above and try again.")
                    return
                }
                guidedSetupLog.append("✓ Isolated agent registered.")
            }

            guidedSetupLog.append("• Writing your tuned workspace…")
            refreshInstallStatus()
            do {
                let report = try WorkspaceInstaller.install(
                    draft: draft,
                    installStatus: installStatus,
                    target: target
                )
                lastInstallReport = report
                lastExportURL = report.destinationURL
                guidedSetupLog.append("✓ Wrote \(report.writtenFileCount) files to \(report.destinationURL.path()).")
                if let backupURL = report.backupURL {
                    guidedSetupLog.append("• Previous workspace backed up to \(backupURL.path()).")
                }
            } catch {
                guidedSetupLog.append("✗ Workspace install failed: \(error.localizedDescription)")
                guidedSetupLog.append("• Nothing has been overwritten. Try a Dry run to Desktop to sanity-check the generated files, or check folder permissions on ~/.openclaw/.")
                return
            }

            guidedSetupLog.append("✓ Done. Your agent is ready — open Terminal and run `openclaw dashboard` to say hi.")
            guidedSetupLog.append("• You can re-run this any time. Your openclaw.json is never touched; only the workspace folder is rewritten, and the previous one is always backed up.")
        }
    }

    /// Small helper that waits for the installer runner to flip back
    /// to idle after a command starts. We poll on `isRunning` because
    /// `Process.terminationHandler` is the source of truth and already
    /// drives that property.
    private func runAndWait(_ start: () -> Void) async {
        start()
        while openClawInstaller.isRunning {
            try? await Task.sleep(nanoseconds: 150_000_000)
        }
    }

    private func ensurePreviewSelection() {
        guard generatedFiles.contains(where: { $0.path == selectedPreviewPath }) else {
            selectedPreviewPath = generatedFiles.first?.path ?? ""
            return
        }
    }
}
