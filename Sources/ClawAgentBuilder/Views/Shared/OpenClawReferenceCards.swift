import AppKit
import SwiftUI

/// Bundles the static-knowledge cards into reusable views. These are
/// all rendered from `OpenClawKnowledge` so the copy is grounded in the
/// official docs and stays consistent across the app.

// MARK: - CLI cheatsheet

struct CLICheatsheetCard: View {
    @Bindable var store: BuilderStore
    @State private var expandedGroupID: String? = "core"

    var body: some View {
        SurfaceCard(title: "OpenClaw CLI cheatsheet", icon: "terminal.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text(BuildFlavor.isAppStore
                     ? "Every command here runs against the `openclaw` CLI installed on this Mac. Click Copy to grab one, then paste it into Terminal."
                     : "Every command here runs against the `openclaw` CLI installed on this Mac. Click Copy to grab one, or Run in Terminal to fire it without leaving the app.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(OpenClawKnowledge.cliGroups) { group in
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedGroupID == group.id },
                                set: { expandedGroupID = $0 ? group.id : nil }
                            )
                        ) {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(group.commands) { cmd in
                                    CommandRow(command: cmd, installer: store.openClawInstaller)
                                }
                            }
                            .padding(.top, 6)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(group.title).font(.headline)
                                Text(group.blurb)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(8)
                        .background(.quaternary.opacity(0.2), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
    }

    private struct CommandRow: View {
        let command: OpenClawKnowledge.CLICommand
        @Bindable var installer: OpenClawInstaller

        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(command.command)
                        .font(.system(size: 12, design: .monospaced))
                        .textSelection(.enabled)
                    Text(command.purpose)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 6)
                Button("Copy") {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.setString(command.command, forType: .string)
                }
                .controlSize(.small)
                if !BuildFlavor.isAppStore {
                    Button("Run in Terminal") { installer.runInTerminal(command.command) }
                        .controlSize(.small)
                }
            }
            .padding(8)
            .background(.quaternary.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

// MARK: - Troubleshooting first-aid

struct TroubleshootingCard: View {
    @Bindable var store: BuilderStore

    var body: some View {
        SurfaceCard(title: "Troubleshooting first-aid", icon: "cross.case") {
            VStack(alignment: .leading, spacing: 10) {
                Text("When something feels off, try these in order. Most issues are fixed by restarting the gateway or running the doctor.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(OpenClawKnowledge.troubleshooting) { tip in
                        VStack(alignment: .leading, spacing: 6) {
                            Label(tip.symptom, systemImage: "questionmark.circle")
                                .font(.headline)
                            Text(tip.tryThis)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            if let cmd = tip.command {
                                HStack(alignment: .center, spacing: 8) {
                                    Text(cmd)
                                        .font(.system(size: 12, design: .monospaced))
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                        .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    Button("Copy") {
                                        let pb = NSPasteboard.general
                                        pb.clearContents()
                                        pb.setString(cmd, forType: .string)
                                    }
                                    .controlSize(.small)
                                    if !BuildFlavor.isAppStore {
                                        Button("Run in Terminal") { store.openClawInstaller.runInTerminal(cmd) }
                                            .controlSize(.small)
                                    }
                                }
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.quaternary.opacity(0.2), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
    }
}

// MARK: - Workspace files reference

struct WorkspaceFilesReferenceCard: View {
    var body: some View {
        SurfaceCard(title: "What lives in your workspace", icon: "folder.badge.gearshape") {
            VStack(alignment: .leading, spacing: 10) {
                Text("These are the files OpenClaw reads from ~/.openclaw/workspace. The builder fills them in for you, but knowing what each one is helps when you tune by hand later.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(OpenClawKnowledge.workspaceFiles) { file in
                        HStack(alignment: .top, spacing: 10) {
                            Text(file.path)
                                .font(.system(size: 12, design: .monospaced))
                                .frame(width: 180, alignment: .leading)
                                .textSelection(.enabled)
                            Text(file.purpose)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                        Divider().opacity(0.4)
                    }
                }
            }
        }
    }
}

// MARK: - Environment variables

struct EnvVariablesReferenceCard: View {
    var body: some View {
        SurfaceCard(title: "Environment variables OpenClaw reads", icon: "doc.plaintext") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Set these in your shell profile to override OpenClaw defaults. Useful when you run more than one install, or when the defaults collide with another tool.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(OpenClawKnowledge.environmentVariables) { env in
                        HStack(alignment: .top, spacing: 10) {
                            Text(env.name)
                                .font(.system(size: 12, design: .monospaced))
                                .frame(width: 200, alignment: .leading)
                                .textSelection(.enabled)
                            Text(env.purpose)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

// MARK: - Wizard flags

struct WizardFlagsCard: View {
    var body: some View {
        SurfaceCard(title: "Onboarding wizard flags", icon: "flag") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Pass these to `openclaw onboard` when you need scripted or non-interactive setup — useful for CI or provisioning a teammate's Mac.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(OpenClawKnowledge.wizardFlags) { flag in
                        HStack(alignment: .top, spacing: 10) {
                            Text(flag.flag)
                                .font(.system(size: 12, design: .monospaced))
                                .frame(width: 260, alignment: .leading)
                                .textSelection(.enabled)
                            Text(flag.purpose)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

// MARK: - Channels catalog

struct ChannelsCatalogCard: View {
    var body: some View {
        SurfaceCard(title: "Channels OpenClaw supports", icon: "bubble.left.and.bubble.right") {
            VStack(alignment: .leading, spacing: 10) {
                Text("These are the places your agent can speak. You only fill in credentials for the ones you actually want — OpenClaw ignores the rest.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                ForEach(groupedChannels, id: \.0) { category, names in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category)
                            .font(.headline)
                        Text(names.joined(separator: " · "))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(.quaternary.opacity(0.2), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }

    private var groupedChannels: [(String, [String])] {
        let grouped = Dictionary(grouping: OpenClawKnowledge.channels, by: { $0.category })
        let order = ["Enterprise / team", "Consumer", "Specialized"]
        return order.compactMap { cat in
            guard let items = grouped[cat] else { return nil }
            return (cat, items.map { $0.name })
        }
    }
}

// MARK: - Skills catalog

struct SkillsCatalogCard: View {
    var body: some View {
        SurfaceCard(title: "Built-in skill categories", icon: "sparkles.rectangle.stack") {
            VStack(alignment: .leading, spacing: 10) {
                Text("OpenClaw ships reusable ability packs. Install only the ones your agent actually needs — they're managed with `openclaw skills`.")
                    .foregroundStyle(.secondary)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(OpenClawKnowledge.skillCategories) { skill in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(skill.name).font(.headline)
                            Text(skill.examples)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(.quaternary.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
        }
    }
}

// MARK: - Model providers catalog

struct ModelProvidersCatalogCard: View {
    var body: some View {
        SurfaceCard(title: "Supported model providers", icon: "cpu") {
            VStack(alignment: .leading, spacing: 8) {
                Text("OpenClaw is provider-agnostic. Anthropic (Claude) is the default and recommended; everything else can be wired in as a secondary or fallback.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                Text(OpenClawKnowledge.supportedModelProviders.joined(separator: " · "))
                    .font(.callout)
                    .textSelection(.enabled)
            }
        }
    }
}
