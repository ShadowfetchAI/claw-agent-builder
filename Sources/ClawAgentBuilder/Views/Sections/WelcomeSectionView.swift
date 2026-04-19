import SwiftUI

struct WelcomeSectionView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            OakHeroPanel {
                HStack(alignment: .top, spacing: 28) {
                    if let icon = ModuleArtwork.appIcon.image {
                        Image(nsImage: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 240, height: 356)
                            .oakFramedImage()
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        OakStatPill(text: "Classy, steady, OpenClaw-native")

                        Text("Build your OpenClaw agent one clear step at a time.")
                            .font(.system(size: 36, weight: .bold, design: .serif))

                        Text("This app guides the official OpenClaw install, then helps you shape the agent files and settings in plain English.")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        Text("Nothing is locked in. You can build now, retune later, and keep refining the same agent as your workflow gets sharper.")
                            .font(.headline)
                            .foregroundStyle(OakPalette.brass)
                    }
                }
            }

            PageGuideCard(section: .welcome)

            StartingPathCard(store: store)

            OnboardingChecklistCard(store: store)

            SurfaceCard(title: "Start here", icon: "hand.wave.fill") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("If you're new to AI tools or new to OpenClaw, start by picking a preset below. That gives the builder a sensible starting shape.")
                        .foregroundStyle(.secondary)

                    if BuildFlavor.isAppStore {
                        Text("This edition focuses on shaping your agent files. When you're ready to install OpenClaw itself, follow the official one-liner from docs.openclaw.ai in Terminal — it's a one-time setup.")
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        Button {
                            store.goToSection(.identity)
                        } label: {
                            Label("Start shaping your agent", systemImage: "arrow.right.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("Later, the official onboarding step may still open Terminal because OpenClaw owns that part of the setup. The app explains that before it happens.")
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        Button {
                            store.goToSection(.openClawInstall)
                        } label: {
                            Label("Go to Step 2: Install OpenClaw", systemImage: "arrow.right.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }

            SurfaceCard(title: "Choose a starting preset", icon: "wand.and.stars") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("A preset is just a starting shape. Pick the one that sounds closest to the agent you want, then the next pages will fine-tune it.")
                        .foregroundStyle(.secondary)

                    if store.canUndoPreset {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.uturn.backward.circle")
                            Text("Just applied a preset. Not what you wanted?")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Button("Undo preset") { store.undoPreset() }
                                .buttonStyle(.bordered)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.quaternary.opacity(0.2), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(AgentPresets.all) { preset in
                            Button {
                                store.applyPreset(preset)
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: preset.symbolName)
                                        .font(.title3)
                                        .foregroundStyle(OakPalette.brass)
                                        .frame(width: 26)

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Text(preset.title)
                                                .font(.headline)
                                            if preset.id == AgentPresets.founderCopilot.id {
                                                OakStatPill(text: "Recommended first build")
                                            }
                                        }

                                        Text(preset.tagline)
                                            .font(.callout)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }

                                    Spacer(minLength: 0)

                                    Text("Use preset")
                                        .font(.callout.weight(.semibold))
                                        .foregroundStyle(OakPalette.brass)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(OakPalette.insetGradient)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(OakPalette.border, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

/// The big fork-in-the-road card: existing-OpenClaw users skip straight
/// to Identity; first-timers go to the full install page. Kept near the
/// top of Welcome so a newcomer never wonders which lane is theirs.
struct StartingPathCard: View {
    @Bindable var store: BuilderStore

    var body: some View {
        SurfaceCard(title: "How are you starting?", icon: "signpost.right.and.left.fill") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Pick the lane that matches your Mac. You can always switch later — this just sets where we take you next.")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(visiblePaths) { path in
                        pathButton(path)
                    }
                }

                if BuildFlavor.isAppStore {
                    Text("You're running the App Store edition. This build generates your agent files and validates your API keys — installing OpenClaw itself is done once in Terminal using the official one-liner from docs.openclaw.ai.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }

                if let picked = store.startingPath {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("You picked: \(picked.title).")
                            .font(.callout)
                        Spacer()
                        Button("Change") { store.startingPath = nil }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary.opacity(0.2), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }

    /// App Store edition hides the "full install" path because
    /// sandboxed apps can't run the official installer.
    private var visiblePaths: [StartingPath] {
        if BuildFlavor.isAppStore {
            return [.existingOpenClaw]
        }
        return StartingPath.allCases
    }

    private func pathButton(_ path: StartingPath) -> some View {
        let isPicked = store.startingPath == path
        return Button {
            store.chooseStartingPath(path)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: path.symbolName)
                    .font(.title2)
                    .foregroundStyle(OakPalette.brass)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(path.title).font(.headline)
                        if isPicked {
                            OakStatPill(text: "Selected")
                        }
                    }
                    Text(path.tagline)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Text(path == .existingOpenClaw ? "Go to Identity" : "Go to Install")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(OakPalette.brass)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(OakPalette.insetGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isPicked ? OakPalette.brass : OakPalette.border, lineWidth: isPicked ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
