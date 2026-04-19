import SwiftUI

struct OpenClawInstallSectionView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PageGuideCard(section: .openClawInstall)

            PrerequisitesCard(store: store)

            if let err = store.openClawInstaller.terminalAutomationError {
                SurfaceCard(title: "Terminal didn't open", icon: "exclamationmark.triangle.fill") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(err)
                            .foregroundStyle(.secondary)
                        Button("Dismiss") { store.openClawInstaller.terminalAutomationError = nil }
                            .buttonStyle(.bordered)
                    }
                }
            }

            SurfaceCard(title: store.installStatus.readiness.title, icon: "checkmark.shield") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(store.installStatus.summary)
                    Text(store.installStatus.recommendation)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Re-check install status") { store.refreshInstallStatus() }
                        if let cli = store.installStatus.cliPath {
                            Text("CLI: \(cli)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                    }
                }
            }

            if guidedSetupSucceeded {
                GuidedSetupSuccessCard(store: store)
            }

            SurfaceCard(title: "Guided setup (install + build in one shot)", icon: "wand.and.rays") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("This handles the easy automation safely: install the OpenClaw CLI if needed, send the official onboarding step to Terminal when OpenClaw needs a real TTY, and then lay down the tuned workspace you designed here.")
                        .foregroundStyle(.secondary)

                    Text("Skips install when the CLI is already present and skips onboarding when ~/.openclaw/openclaw.json already exists, so re-running won't clobber what's already working.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        Button {
                            store.runGuidedSetup(target: .liveMainWorkspace)
                        } label: {
                            Label("Install OpenClaw + build my agent (live)", systemImage: "sparkles")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(store.guidedSetupIsRunning || !store.canInstallToLiveTarget)

                        Button {
                            store.runGuidedSetup(target: .desktopPackage)
                        } label: {
                            Label("Dry run to Desktop", systemImage: "tray.and.arrow.down")
                        }
                        .disabled(store.guidedSetupIsRunning)
                    }

                    if !store.canInstallToLiveTarget {
                        Label("Name your agent in Identity before running a live install.", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                            .font(.callout)
                    }

                    if !store.guidedSetupLog.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(store.guidedSetupLog.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(.callout)
                                    .textSelection(.enabled)
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }

            SurfaceCard(title: "Or run the official steps one at a time", icon: "list.number") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("The onboarding step is intentionally launched in Terminal because that is the official interactive path and I do not want the app faking that experience.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(OpenClawInstaller.steps) { step in
                        RunnableCommandRow(
                            title: step.title,
                            command: step.command,
                            installer: store.openClawInstaller,
                            onRun: { runStep(step) }
                        )
                    }
                }
            }

            SurfaceCard(title: "Live install log", icon: "terminal") {
                VStack(alignment: .leading, spacing: 8) {
                    if store.openClawInstaller.runningCommandTitle.isEmpty == false {
                        HStack(spacing: 8) {
                            ProgressView().controlSize(.small)
                            Text(store.openClawInstaller.runningCommandTitle)
                                .font(.callout)
                        }
                    }

                    ScrollView {
                        Text(store.openClawInstaller.output.isEmpty
                             ? "No commands run yet. Output from the Run buttons above will stream here."
                             : store.openClawInstaller.output)
                            .font(.system(size: 12, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 160, maxHeight: 260)
                    .padding(10)
                    .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    HStack {
                        if store.openClawInstaller.isRunning {
                            Button("Cancel running command") { store.openClawInstaller.cancel() }
                                .foregroundStyle(.red)
                        }
                        Spacer()
                        if let exit = store.openClawInstaller.lastExitCode {
                            Text(exit == 0 ? "Last run: success" : "Last run: exit \(exit)")
                                .font(.caption)
                                .foregroundStyle(exit == 0 ? .green : .red)
                        }
                    }
                }
            }

            WizardPhaseMapCard()

            OpenClawGlossaryCard()

            CLICheatsheetCard(store: store)

            TroubleshootingCard(store: store)

            WorkspaceFilesReferenceCard()

            EnvVariablesReferenceCard()

            WizardFlagsCard()

            ChannelsCatalogCard()

            SkillsCatalogCard()

            ModelProvidersCatalogCard()

            SurfaceCard(title: "Official docs", icon: "doc.badge.gearshape") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("If you prefer to read first, these are the official references this app wraps:")
                        .foregroundStyle(.secondary)
                    if let url = URL(string: "https://docs.openclaw.ai/start/getting-started") {
                        Link("Getting Started", destination: url)
                    }
                    if let url = URL(string: "https://docs.openclaw.ai/start/onboarding-overview") {
                        Link("Onboarding Overview", destination: url)
                    }
                    if let url = URL(string: "https://docs.openclaw.ai/start/wizard") {
                        Link("Onboarding (CLI)", destination: url)
                    }
                }
            }

            SurfaceCard(title: "How CLAW AGENT BUILDER fits", icon: "point.3.connected.trianglepath.dotted") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("OpenClaw owns the engine: gateway, model auth, channels, daemon, and the default workspace shape.")
                    Text("This app bridges install and tuning: same install path as the official docs, but the workspace that lands at the end is the one you designed here instead of the stock default.")
                    Text("Your ~/.openclaw/openclaw.json is never overwritten by the builder. The app only writes workspace files and gives you a separate config patch file to review by hand.")
                }
                .foregroundStyle(.secondary)
            }
        }
    }

    /// True when guided setup finished without aborting. We key off the
    /// last-line-contains-"✓ Done" convention from BuilderStore so we
    /// don't have to add a second piece of state just for the card.
    private var guidedSetupSucceeded: Bool {
        guard !store.guidedSetupIsRunning else { return false }
        return store.guidedSetupLog.last?.contains("✓ Done") == true
    }

    private func runStep(_ step: OpenClawInstaller.Step) {
        switch step.id {
        case "install": store.openClawInstaller.runInstall()
        case "onboard": store.openClawInstaller.runInTerminal(step.command)
        case "status": store.openClawInstaller.runGatewayStatus()
        default: break
        }
    }
}

/// One row in the "official steps" list. Shows the command, lets the
/// user run it inline, copy it, or run it in Terminal when the command
/// expects the official interactive flow.
private struct RunnableCommandRow: View {
    let title: String
    let command: String
    @Bindable var installer: OpenClawInstaller
    let onRun: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            Text(command)
                .font(.system(size: 12.5, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            HStack(spacing: 8) {
                Button("Run") { onRun() }
                    .buttonStyle(.borderedProminent)
                    .disabled(installer.isRunning)
                Button("Copy") { installer.copyToClipboard(command) }
                Button("Run in Terminal") { installer.runInTerminal(command) }
            }
        }
        .padding(10)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// Surfaces Node.js + Homebrew status before the guided setup runs so
/// newbies don't hit a cryptic "command not found: node" from OpenClaw
/// itself. The one-click fix uses Homebrew when it's already installed
/// and otherwise sends the user to nodejs.org.
private struct PrerequisitesCard: View {
    @Bindable var store: BuilderStore

    var body: some View {
        SurfaceCard(title: "Before you install", icon: "checklist") {
            VStack(alignment: .leading, spacing: 12) {
                Text("OpenClaw needs Node.js to run. This card confirms your Mac is ready so the guided install doesn't stop halfway.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                nodeRow

                brewRow

                HStack(spacing: 10) {
                    Button {
                        store.prereqChecker.refresh()
                    } label: {
                        Label(store.prereqChecker.isChecking ? "Checking…" : "Re-check", systemImage: "arrow.clockwise")
                    }
                    .disabled(store.prereqChecker.isChecking)

                    if let date = store.prereqChecker.lastCheckedAt {
                        Text("Last checked \(date.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .task {
            if store.prereqChecker.lastCheckedAt == nil {
                store.prereqChecker.refresh()
            }
        }
    }

    @ViewBuilder
    private var nodeRow: some View {
        switch store.prereqChecker.node.state {
        case .ok(let version):
            Label("Node.js \(version) — good to go", systemImage: "checkmark.seal.fill")
                .foregroundStyle(.green)
        case .missing:
            VStack(alignment: .leading, spacing: 6) {
                Label("Node.js not found", systemImage: "xmark.octagon.fill")
                    .foregroundStyle(.red)
                Text("OpenClaw requires Node.js 22.14+ or 24.x. Install it once and you're set for every agent you build from here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    if store.prereqChecker.brew.isInstalled {
                        Button {
                            store.openClawInstaller.runInTerminal("brew install node")
                        } label: {
                            Label("Install Node via Homebrew", systemImage: "shippingbox")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    if let url = URL(string: "https://nodejs.org/en/download") {
                        Link("Download from nodejs.org", destination: url)
                    }
                }
            }
        case .tooOld(let found, let minimum):
            VStack(alignment: .leading, spacing: 6) {
                Label("Node.js \(found) is older than \(minimum)", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Upgrade to 22.14+ or 24.x so OpenClaw can run its gateway and daemon.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if store.prereqChecker.brew.isInstalled {
                    Button {
                        store.openClawInstaller.runInTerminal("brew upgrade node")
                    } label: {
                        Label("Upgrade Node via Homebrew", systemImage: "arrow.up.circle")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var brewRow: some View {
        if store.prereqChecker.brew.isInstalled {
            Label(store.prereqChecker.brew.version ?? "Homebrew available", systemImage: "shippingbox.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Label("Homebrew not detected (optional)", systemImage: "shippingbox")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Homebrew makes one-click Node installs possible. Not required if you install Node manually.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Walks through the seven phases the OpenClaw wizard runs so the user
/// knows what's about to happen in Terminal. Mirrors the official
/// onboarding overview doc.
private struct WizardPhaseMapCard: View {
    private struct Phase: Identifiable {
        let id = UUID()
        let number: Int
        let title: String
        let blurb: String
        let icon: String
    }

    private let phases: [Phase] = [
        Phase(number: 1, title: "Model & auth", blurb: "Pick Anthropic (default), OpenAI-compatible, or a custom provider, then paste the key.", icon: "brain.head.profile"),
        Phase(number: 2, title: "Workspace", blurb: "Confirms ~/.openclaw/workspace (or your isolated slug) and writes default files.", icon: "folder"),
        Phase(number: 3, title: "Gateway", blurb: "Starts the local gateway on port 18789 — the thing OpenClaw talks to locally.", icon: "network"),
        Phase(number: 4, title: "Channels", blurb: "Optional: Telegram, Discord, BlueBubbles, WhatsApp. You can skip and add later.", icon: "antenna.radiowaves.left.and.right"),
        Phase(number: 5, title: "Daemon", blurb: "Installs the background daemon so the agent keeps running when the CLI closes.", icon: "gearshape.2"),
        Phase(number: 6, title: "Health check", blurb: "Pings the gateway on 18789 and confirms the daemon answered. Green = you are live.", icon: "waveform.path.ecg"),
        Phase(number: 7, title: "Skills", blurb: "Installs starter skills. You can add or prune these any time with `openclaw skills`.", icon: "sparkles")
    ]

    var body: some View {
        SurfaceCard(title: "What Terminal is about to do", icon: "map") {
            VStack(alignment: .leading, spacing: 10) {
                Text("When the onboarding step runs in Terminal, it walks through these seven phases. You answer a few prompts per phase. You can re-run onboarding later without losing work.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(phases) { phase in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: phase.icon)
                                .font(.title3)
                                .frame(width: 26)
                                .foregroundStyle(.cyan)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Phase \(phase.number) — \(phase.title)")
                                    .font(.headline)
                                Text(phase.blurb)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

/// Tiny glossary so a newbie clicking through the install page knows
/// what Gateway / Daemon / Workspace / Channel actually mean in
/// OpenClaw's world — before they have to read the docs cold.
private struct OpenClawGlossaryCard: View {
    private struct Term: Identifiable {
        let id = UUID()
        let term: String
        let plainEnglish: String
        let icon: String
    }

    private let terms: [Term] = [
        Term(term: "Gateway", plainEnglish: "Local server (default port 18789) that the CLI and channels talk to. Think of it as the agent's front door.", icon: "network"),
        Term(term: "Daemon", plainEnglish: "Background process that keeps your agent alive after you close Terminal. Installed during onboarding.", icon: "gearshape.2"),
        Term(term: "Workspace", plainEnglish: "Folder (~/.openclaw/workspace) that holds your agent's identity, memory, tools, and skills. What this app tunes for you.", icon: "folder"),
        Term(term: "Channel", plainEnglish: "Places your agent can speak — Terminal, Telegram, Discord, BlueBubbles, WhatsApp. Optional and swappable.", icon: "antenna.radiowaves.left.and.right"),
        Term(term: "Skills", plainEnglish: "Reusable ability packs OpenClaw ships. The daemon loads these at startup; you can add or prune them per workspace.", icon: "sparkles")
    ]

    var body: some View {
        SurfaceCard(title: "Plain-English glossary", icon: "text.book.closed") {
            VStack(alignment: .leading, spacing: 10) {
                Text("You'll hear these words in Terminal and in the docs. Here's what they mean without jargon.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(terms) { term in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: term.icon)
                                .frame(width: 24)
                                .foregroundStyle(.cyan)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(term.term).font(.headline)
                                Text(term.plainEnglish)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}
