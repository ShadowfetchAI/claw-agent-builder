import SwiftUI
import UniformTypeIdentifiers

struct PreviewAndExportSectionView: View {
    @Bindable var store: BuilderStore

    @State private var showingFolderImporter = false
    @State private var showingDraftImporter = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PageGuideCard(section: .preview)

            SurfaceCard(title: "Export summary", icon: "shippingbox.and.arrow.forward") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current file set: \(store.generatedFiles.count) generated files")
                    Text("Agent package name: CLAW Agent Build - \(store.draft.agentSlug)")
                    Text("Build mode: \(store.draft.buildMode.title)")
                    Text("Primary focus: \(store.draft.primaryFocus.title)")
                }
                .foregroundStyle(.secondary)
            }

            SurfaceCard(title: "What the export includes", icon: "doc.on.doc") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Real OpenClaw workspace files: AGENTS, SOUL, IDENTITY, USER, TOOLS, MEMORY, HEARTBEAT, BOOT, BOOTSTRAP, DREAMS, README")
                    Text("• Founder files: FOUNDER, FOUNDER_PROFILE, and the full questionnaire")
                    Text("• memory/<today>.md scaffold and memory/heartbeat-state.json")
                    Text("• openclaw.config.patch.json you can review and merge into ~/.openclaw/openclaw.json")
                    Text("• skills/, avatars/, canvas/ with starter READMEs and bundled assets")
                    Text("• A hidden .claw-builder/builder-profile.json so this draft can be reloaded and retuned")
                }
                .foregroundStyle(.secondary)
            }

            SurfaceCard(title: "Where should it go?", icon: "target") {
                VStack(alignment: .leading, spacing: 12) {
                    if BuildFlavor.isAppStore {
                        Text("This edition runs in Apple's sandbox, so it can only write to a folder you pick. Choose a folder, then copy the generated files into ~/.openclaw/workspace yourself (Finder or Terminal).")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Picker("Install target", selection: targetSelectionBinding) {
                        if !BuildFlavor.isAppStore {
                            Text("Desktop preview (safe — nothing overwritten)").tag(TargetTag.desktop)
                            Text("Live main workspace (~/.openclaw/workspace)").tag(TargetTag.live)
                            Text("Isolated workspace (~/.openclaw/workspace-\(store.draft.agentSlug))").tag(TargetTag.isolated)
                        }
                        Text("Custom folder…").tag(TargetTag.custom)
                    }
                    .pickerStyle(.radioGroup)

                    Text(store.resolvedSelectedTarget().explanation)
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    if case .customFolder = store.selectedInstallTarget {
                        HStack {
                            Text(store.customFolderURL?.path() ?? "No folder chosen yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button("Choose folder…") { showingFolderImporter = true }
                        }
                    }

                    if targetSelectionBinding.wrappedValue != .desktop && !store.canInstallToLiveTarget {
                        Label("Add an agent name in the Identity section before installing here.", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                            .font(.callout)
                    }
                }
            }

            SurfaceCard(title: "Install now", icon: "arrow.down.doc") {
                VStack(alignment: .leading, spacing: 12) {
                    Button(installButtonTitle) {
                        store.install(to: store.resolvedSelectedTarget())
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isInstallDisabled)

                    if let lastExportURL = store.lastExportURL {
                        Text("Last wrote to: \(lastExportURL.path())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    if let backupURL = store.lastInstallReport?.backupURL {
                        Text("Previous workspace backed up to: \(backupURL.path())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
            }

            PreviewPane(store: store)

            SurfaceCard(title: "Drafts", icon: "tray.and.arrow.down") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Button("Save draft") { store.saveDraft() }
                        Button("Load draft…") { showingDraftImporter = true }
                    }
                    let recent = store.recentDrafts()
                    if !recent.isEmpty {
                        Text("Recent")
                            .font(.headline)
                        ForEach(recent, id: \.self) { url in
                            Button {
                                store.loadDraft(from: url)
                            } label: {
                                Label(url.deletingPathExtension().lastPathComponent, systemImage: "doc.text")
                            }
                            .buttonStyle(.link)
                        }
                    } else {
                        Text("No saved drafts yet — hit Save draft to snapshot your current tuning.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            if BuildFlavor.isAppStore {
                switch store.selectedInstallTarget {
                case .customFolder:
                    break
                default:
                    let url = store.customFolderURL ?? FileManager.default.homeDirectoryForCurrentUser
                    store.selectedInstallTarget = .customFolder(url: url)
                }
            }
        }
        .fileImporter(
            isPresented: $showingFolderImporter,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let first = urls.first {
                store.customFolderURL = first
            }
        }
        .fileImporter(
            isPresented: $showingDraftImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let first = urls.first {
                store.loadDraft(from: first)
            }
        }
    }

    // MARK: - Target tag bridging

    private enum TargetTag: Hashable { case desktop, live, isolated, custom }

    private var targetSelectionBinding: Binding<TargetTag> {
        Binding(
            get: {
                switch store.selectedInstallTarget {
                case .desktopPackage: return .desktop
                case .liveMainWorkspace: return .live
                case .isolatedAgent: return .isolated
                case .customFolder: return .custom
                }
            },
            set: { newValue in
                switch newValue {
                case .desktop:
                    store.selectedInstallTarget = .desktopPackage
                case .live:
                    store.selectedInstallTarget = .liveMainWorkspace
                case .isolated:
                    store.selectedInstallTarget = .isolatedAgent(slug: store.draft.agentSlug)
                case .custom:
                    let url = store.customFolderURL ?? FileManager.default.homeDirectoryForCurrentUser
                    store.selectedInstallTarget = .customFolder(url: url)
                }
            }
        )
    }

    private var installButtonTitle: String {
        switch store.selectedInstallTarget {
        case .desktopPackage: return "Export preview to Desktop"
        case .liveMainWorkspace: return "Install into ~/.openclaw/workspace"
        case .isolatedAgent: return "Install isolated agent"
        case .customFolder: return "Write to custom folder"
        }
    }

    private var isInstallDisabled: Bool {
        switch store.selectedInstallTarget {
        case .desktopPackage:
            return false
        case .customFolder:
            return store.customFolderURL == nil || !store.canInstallToLiveTarget
        case .liveMainWorkspace, .isolatedAgent:
            return !store.canInstallToLiveTarget
        }
    }
}
