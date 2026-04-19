import AppKit
import SwiftUI

/// The "pick your providers, paste a key, done" screen. This is the
/// GUI replacement for the classic "edit your .env file" step. Every
/// provider and bridge gets a card that explains what it is, why you'd
/// use it, and links straight to where to grab a key.
struct APIKeysSectionView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PageGuideCard(section: .apiKeys)

            SurfaceCard(title: "How this works", icon: "wand.and.stars") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pick the providers you want to use, paste your key, and we'll turn that into a proper `.env.example` file that ships with your workspace — so you never have to hand-edit shell dotfiles.")
                    Text("By default only the variable names are written out (safe to commit). Flip the toggle at the bottom if you want to bake real keys into the file we generate on disk.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            SurfaceCard(title: "Model providers", icon: "brain.head.profile") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Anthropic is the default — OpenClaw runs best on Claude. Add others as secondary/fallbacks.")
                        .foregroundStyle(.secondary)
                    ForEach(ModelProviderCatalog.all) { provider in
                        ProviderCard(provider: provider, store: store)
                    }
                }
            }

            SurfaceCard(title: "Channel bridges", icon: "antenna.radiowaves.left.and.right") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Only fill these in for channels you actually want your agent to speak over. Leave the rest blank.")
                        .foregroundStyle(.secondary)
                    ForEach(ChannelSecretCatalog.all) { secret in
                        ChannelSecretCard(secret: secret, store: store)
                    }
                }
            }

            SurfaceCard(title: "Generated .env", icon: "doc.text") {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: Binding(
                        get: { store.draft.includeKeysInGeneratedEnv },
                        set: { store.draft.includeKeysInGeneratedEnv = $0 }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Include real keys in the generated .env file")
                            Text("Off = ships env-var names only (safe to commit). On = bakes the keys you typed into the file that lands in your workspace.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(EnvFileGenerator.render(from: store.draft))
                        .font(.system(size: 12, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    HStack {
                        Button {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(EnvFileGenerator.render(from: store.draft), forType: .string)
                        } label: {
                            Label("Copy .env to clipboard", systemImage: "doc.on.doc")
                        }
                        Spacer()
                        Text("Will be written to `.env.example` inside your exported workspace.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

/// One model-provider card: enable toggle, secure key field, signup link,
/// docs link, and an inline explanation.
private struct ProviderCard: View {
    let provider: ModelProvider
    @Bindable var store: BuilderStore

    private var isEnabled: Bool {
        store.draft.enabledProviderIDs.contains(provider.id)
    }

    private var keyBinding: Binding<String> {
        Binding(
            get: { store.draft.apiKeyValues[provider.envKey] ?? "" },
            set: { store.draft.apiKeyValues[provider.envKey] = $0 }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: provider.symbolName)
                    .font(.title2)
                    .foregroundStyle(.cyan)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 3) {
                    Text(provider.title).font(.headline)
                    Text(provider.tagline)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("Use", isOn: Binding(
                    get: { isEnabled },
                    set: { newValue in
                        if newValue {
                            store.draft.enabledProviderIDs.insert(provider.id)
                        } else {
                            store.draft.enabledProviderIDs.remove(provider.id)
                        }
                    }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
            }

            if isEnabled {
                Text(provider.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text(provider.envKey)
                        .font(.system(size: 11, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.quaternary.opacity(0.5), in: Capsule())
                    Text(provider.access.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SecureField(provider.keyHint, text: keyBinding)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 10) {
                    Button {
                        store.providerKeyTester.test(
                            provider: provider,
                            apiKey: store.draft.apiKeyValues[provider.envKey] ?? ""
                        )
                    } label: {
                        if case .testing = store.providerKeyTester.status(for: provider.id) {
                            ProgressView().controlSize(.small)
                        } else {
                            Label("Test key", systemImage: "bolt.badge.checkmark")
                        }
                    }
                    .disabled({
                        if case .testing = store.providerKeyTester.status(for: provider.id) { return true }
                        return (store.draft.apiKeyValues[provider.envKey] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }())

                    if let url = URL(string: provider.signupURL) {
                        Link("Get a key", destination: url)
                    }
                    if let url = URL(string: provider.docsURL) {
                        Link("Docs", destination: url)
                    }
                }
                .font(.callout)

                // Inline status line — green check on OK, red on auth /
                // network failure, hidden when idle so the card stays
                // calm until the user actually hits Test.
                switch store.providerKeyTester.status(for: provider.id) {
                case .idle, .testing:
                    EmptyView()
                case .ok(let message):
                    Label(message, systemImage: "checkmark.seal.fill")
                        .font(.callout)
                        .foregroundStyle(.green)
                case .failed(let message):
                    Label(message, systemImage: "xmark.octagon.fill")
                        .font(.callout)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(12)
        .background(.quaternary.opacity(isEnabled ? 0.35 : 0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// One channel/bridge credential card — same shape as ProviderCard but
/// for Telegram, Discord, BlueBubbles, WhatsApp.
private struct ChannelSecretCard: View {
    let secret: ChannelSecret
    @Bindable var store: BuilderStore

    private var isEnabled: Bool {
        store.draft.enabledChannelSecretIDs.contains(secret.id)
    }

    private var keyBinding: Binding<String> {
        Binding(
            get: { store.draft.apiKeyValues[secret.envKey] ?? "" },
            set: { store.draft.apiKeyValues[secret.envKey] = $0 }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: secret.symbolName)
                    .font(.title2)
                    .foregroundStyle(.cyan)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 3) {
                    Text(secret.title).font(.headline)
                    Text(secret.tagline)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("Use", isOn: Binding(
                    get: { isEnabled },
                    set: { newValue in
                        if newValue {
                            store.draft.enabledChannelSecretIDs.insert(secret.id)
                        } else {
                            store.draft.enabledChannelSecretIDs.remove(secret.id)
                        }
                    }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
            }

            if isEnabled {
                Text(secret.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(secret.envKey)
                    .font(.system(size: 11, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.quaternary.opacity(0.5), in: Capsule())

                SecureField(secret.keyHint, text: keyBinding)
                    .textFieldStyle(.roundedBorder)

                if let url = URL(string: secret.signupURL) {
                    Link("Where to get this", destination: url)
                        .font(.callout)
                }
            }
        }
        .padding(12)
        .background(.quaternary.opacity(isEnabled ? 0.35 : 0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
