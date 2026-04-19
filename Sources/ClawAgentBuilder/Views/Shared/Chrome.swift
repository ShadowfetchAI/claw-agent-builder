import AppKit
import SwiftUI

enum OakPalette {
    static let brass = Color(red: 0.80, green: 0.63, blue: 0.34)
    static let brassSoft = Color(red: 0.62, green: 0.48, blue: 0.25)
    static let sage = Color(red: 0.48, green: 0.61, blue: 0.45)
    static let walnutTop = Color(red: 0.23, green: 0.17, blue: 0.12)
    static let walnutBottom = Color(red: 0.08, green: 0.06, blue: 0.05)
    static let panelTop = Color(red: 0.27, green: 0.20, blue: 0.15)
    static let panelBottom = Color(red: 0.15, green: 0.11, blue: 0.08)
    static let panelLift = Color.white.opacity(0.05)
    static let insetTop = Color(red: 0.12, green: 0.09, blue: 0.07)
    static let insetBottom = Color(red: 0.07, green: 0.05, blue: 0.04)
    static let border = brass.opacity(0.28)
    static let borderStrong = brass.opacity(0.46)
    static let shadow = Color.black.opacity(0.34)
    static let mist = Color.white.opacity(0.035)

    static let workbenchGradient = LinearGradient(
        colors: [walnutTop, panelBottom, walnutBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panelGradient = LinearGradient(
        colors: [panelTop, panelBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let insetGradient = LinearGradient(
        colors: [insetTop, insetBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct OakWorkbenchBackground: View {
    var body: some View {
        ZStack {
            OakPalette.workbenchGradient
                .ignoresSafeArea()

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [OakPalette.brass.opacity(0.18), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 88)
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()

            Circle()
                .fill(OakPalette.brass.opacity(0.10))
                .frame(width: 520, height: 520)
                .blur(radius: 120)
                .offset(x: 360, y: -260)

            Circle()
                .fill(OakPalette.mist)
                .frame(width: 420, height: 420)
                .blur(radius: 130)
                .offset(x: -420, y: 260)
        }
    }
}

struct SurfaceCard<Content: View>: View {
    let title: String
    var icon: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(OakPalette.brass)
                }

                Text(title)
                    .font(.system(.headline, design: .serif, weight: .semibold))
            }

            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(OakPalette.panelGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(OakPalette.border, lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(OakPalette.panelLift, lineWidth: 1)
                .blur(radius: 0.2)
        )
        .shadow(color: OakPalette.shadow, radius: 20, y: 14)
    }
}

struct OakInsetSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(OakPalette.insetGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(OakPalette.border, lineWidth: 1)
            )
    }
}

extension View {
    func oakInsetSurface() -> some View {
        modifier(OakInsetSurface())
    }

    func oakFramedImage() -> some View {
        clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(OakPalette.borderStrong, lineWidth: 1.5)
            )
            .shadow(color: OakPalette.shadow, radius: 22, y: 14)
    }
}

struct OakStatPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.88))
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [OakPalette.brassSoft.opacity(0.88), OakPalette.panelTop.opacity(0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .strokeBorder(OakPalette.border, lineWidth: 1)
            )
    }
}

struct OakHeroPanel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            content
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [OakPalette.panelTop, OakPalette.walnutTop],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(OakPalette.borderStrong, lineWidth: 1.2)
        )
        .shadow(color: OakPalette.shadow, radius: 28, y: 18)
    }
}

struct CommandBlock: View {
    let title: String
    let command: String

    var body: some View {
        SurfaceCard(title: title, icon: "terminal") {
            Text(command)
                .font(.system(size: 12.5, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .oakInsetSurface()
        }
    }
}

struct OfficeGalleryView: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(Array(ModuleArtwork.officeGallery.enumerated()), id: \.offset) { index, artwork in
                    if let image = artwork.image {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 260, height: 180)
                            .oakFramedImage()
                            .overlay(alignment: .bottomLeading) {
                                Text("Lobster office \(index + 1)")
                                    .font(.caption.weight(.medium))
                                    .padding(8)
                                    .background(
                                        Capsule()
                                            .fill(OakPalette.insetGradient)
                                    )
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(OakPalette.border, lineWidth: 1)
                                    )
                                    .padding(10)
                            }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
    }
}

struct TipLabel: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(OakPalette.brass)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [OakPalette.panelTop.opacity(0.94), OakPalette.panelBottom.opacity(0.94)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule()
                .strokeBorder(OakPalette.border, lineWidth: 1)
        )
    }
}

/// Live 5-step "where am I in setup" checklist for the Welcome page.
/// Each row has a click-to-jump behaviour so a first-time user can
/// plant themselves at the next unchecked step without thinking about
/// sidebar navigation.
struct OnboardingChecklistCard: View {
    @Bindable var store: BuilderStore

    private struct Step: Identifiable {
        let id: BuilderSection
        let title: String
        let hint: String
    }

    private let steps: [Step] = [
        .init(id: .identity, title: "Name your agent", hint: "Give it a name, nickname, and a few words of vibe."),
        .init(id: .apiKeys, title: "Pick a model + paste a key", hint: "Anthropic is the default. One key is enough to start."),
        .init(id: .openClawInstall, title: "Install OpenClaw", hint: "Guided setup installs the CLI and wires your agent up."),
        .init(id: .focus, title: "Choose a focus", hint: "What jobs should this agent actually do?"),
        .init(id: .preview, title: "Export or install", hint: "Desktop preview first, then install for real.")
    ]

    var body: some View {
        SurfaceCard(title: "Your onboarding checklist", icon: "checklist") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(steps) { step in
                    let completion = store.sectionCompletion(step.id)
                    Button {
                        store.goToSection(step.id)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: completion.symbolName)
                                .foregroundStyle(completion == .done ? .green : .secondary)
                                .font(.title3)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(step.hint)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(completion == .done ? Color.green.opacity(0.08) : Color.secondary.opacity(0.05))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// Success celebration that appears after the guided install finishes
/// cleanly. Beginners need the dopamine hit, and this also gives the
/// honest next-action ("run `openclaw dashboard` to say hi") so they
/// know what to do next.
struct GuidedSetupSuccessCard: View {
    @Bindable var store: BuilderStore

    var body: some View {
        SurfaceCard(title: "🎉 Your agent is live", icon: "party.popper") {
            VStack(alignment: .leading, spacing: 10) {
                Text("OpenClaw is installed and your tuned workspace is on disk. The agent you just designed is what answers the first time you open a conversation.")
                    .foregroundStyle(.secondary)

                if let url = store.lastExportURL {
                    Text("Workspace: \(url.path())")
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    Button {
                        store.openClawInstaller.runInTerminal("openclaw dashboard")
                    } label: {
                        Label("Open dashboard", systemImage: "rectangle.inset.filled.and.person.filled")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        if let url = store.lastExportURL {
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        }
                    } label: {
                        Label("Reveal in Finder", systemImage: "folder")
                    }
                }
            }
        }
    }
}

struct PageGuideCard: View {
    let section: BuilderSection

    var body: some View {
        SurfaceCard(title: "This step", icon: "map") {
            VStack(alignment: .leading, spacing: 12) {
                Text(section.pageLead)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(Array(section.pageSteps.prefix(2)).enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(OakPalette.brass.opacity(0.18)))
                                .foregroundStyle(OakPalette.brass)

                            Text(step)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Label(section.pageNextHint, systemImage: "arrow.right")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct WizardHeaderBar: View {
    @Bindable var store: BuilderStore

    private var current: BuilderSection { store.selectedSection }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 14) {
                if let icon = ModuleArtwork.appIcon.image {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 74, height: 110)
                        .oakFramedImage()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("CLAW AGENT BUILDER")
                        .font(.system(.title3, design: .serif, weight: .semibold))
                    Text("A guided OpenClaw installer and agent forge")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                OakStatPill(text: "Step \(current.stepNumber) of \(BuilderSection.allCases.count)")
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(current.title)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                Text(current.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            WizardStepStrip(store: store)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [OakPalette.panelTop.opacity(0.98), OakPalette.panelBottom.opacity(0.98)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(OakPalette.borderStrong, lineWidth: 1)
        )
        .shadow(color: OakPalette.shadow, radius: 24, y: 14)
    }
}

struct WizardStepStrip: View {
    @Bindable var store: BuilderStore

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(BuilderSection.allCases) { section in
                    let completion = store.sectionCompletion(section)
                    let isUnlocked = store.isSectionUnlocked(section)
                    Button {
                        store.goToSection(section)
                    } label: {
                        HStack(spacing: 8) {
                            Text("\(section.stepNumber)")
                                .font(.caption.weight(.bold))
                                .frame(width: 22, height: 22)
                                .background(
                                    Circle()
                                        .fill(section == store.selectedSection ? OakPalette.brass.opacity(0.88) : OakPalette.brass.opacity(0.16))
                                )
                                .foregroundStyle(section == store.selectedSection ? Color.black.opacity(0.8) : OakPalette.brass)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(section.title)
                                    .font(.caption.weight(.semibold))
                                Text(completionLabel(for: completion))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Image(systemName: completion.symbolName)
                                .font(.caption)
                                .foregroundStyle(completion == .done ? OakPalette.sage : .secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(section == store.selectedSection ? OakPalette.panelGradient : OakPalette.insetGradient)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(section == store.selectedSection ? OakPalette.borderStrong : OakPalette.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isUnlocked)
                    .opacity(isUnlocked ? 1 : 0.58)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }

    private func completionLabel(for completion: SectionCompletion) -> String {
        switch completion {
        case .done:
            return "Ready"
        case .inProgress:
            return "In progress"
        case .notStarted:
            return "Not started"
        }
    }
}

/// Uniform footer the main section views can drop in at the bottom
/// to give first-time users a clear "next" nudge without forcing them
/// back to the sidebar. Shows overall progress and a single big
/// button that jumps to the next section.
struct SectionFooterView: View {
    @Bindable var store: BuilderStore
    let current: BuilderSection

    private var doneCount: Int {
        BuilderSection.allCases.filter { store.sectionCompletion($0) == .done }.count
    }

    private var progress: Double {
        Double(doneCount) / Double(BuilderSection.allCases.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Progress: \(doneCount) of \(BuilderSection.allCases.count) sections")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let saved = store.lastAutosaveAt {
                    Label("Autosaved \(saved.formatted(.relative(presentation: .named)))", systemImage: "checkmark.icloud")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let last = store.lastExportURL {
                    Text("Last export: \(last.lastPathComponent)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            ProgressView(value: progress)
                .tint(OakPalette.brass)

            HStack(spacing: 10) {
                if current.previous != nil {
                    Button {
                        store.moveToPreviousSection()
                    } label: {
                        Label("Back", systemImage: "arrow.left")
                    }
                }

                if let next = current.next {
                    VStack(alignment: .leading, spacing: 4) {
                        Button {
                            store.moveToNextSection()
                        } label: {
                            Label("Next: \(next.title)", systemImage: "arrow.right.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(store.sectionCompletion(current) != .done)

                        if store.sectionCompletion(current) != .done {
                            Text("Finish this step to unlock the next page.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text("You're at the last step. Review carefully, then export or install.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    store.saveDraft()
                } label: {
                    Label("Save draft", systemImage: "tray.and.arrow.down")
                }
                .keyboardShortcut("s", modifiers: .command)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(OakPalette.panelGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(OakPalette.border, lineWidth: 1)
        )
    }
}

struct QuestionAnswerCard: View {
    let question: FounderQuestion
    @Binding var answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(question.number). \(question.prompt)")
                .font(.subheadline.weight(.medium))

            TextEditor(text: $answer)
                .font(.body)
                .frame(minHeight: 84)
                .padding(8)
                .oakInsetSurface()
        }
    }
}
