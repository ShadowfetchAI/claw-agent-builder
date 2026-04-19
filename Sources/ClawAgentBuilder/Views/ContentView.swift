import SwiftUI

struct ContentView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        ZStack {
            OakWorkbenchBackground()

            VStack(spacing: 18) {
                WizardHeaderBar(store: store)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        currentSectionView
                        SectionFooterView(store: store, current: store.selectedSection)
                    }
                    .frame(maxWidth: 980, alignment: .topLeading)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)
                }
            }
            .padding(18)
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    store.refreshInstallStatus()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
                .help("Re-check OpenClaw install status (⌘R)")

                Button {
                    store.saveDraft()
                } label: {
                    Label("Save draft", systemImage: "tray.and.arrow.down")
                }
                .keyboardShortcut("s", modifiers: .command)
                .help("Save the current draft (⌘S)")

                // Invisible shortcuts for fast section nav. Hidden from
                // the toolbar bar but active anywhere in the window.
                Button("Next section") { store.moveToNextSection() }
                    .keyboardShortcut("]", modifiers: .command)
                    .opacity(0)
                    .frame(width: 0, height: 0)

                Button("Previous section") { store.moveToPreviousSection() }
                    .keyboardShortcut("[", modifiers: .command)
                    .opacity(0)
                    .frame(width: 0, height: 0)
            }
        }
        .alert(store.alertTitle, isPresented: $store.showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.alertMessage)
        }
        .onAppear {
            store.refreshInstallStatus()
        }
    }

    @ViewBuilder
    private var currentSectionView: some View {
        switch store.selectedSection {
        case .welcome:
            WelcomeSectionView(store: store)
        case .openClawInstall:
#if APPSTORE_BUILD
            // Sandbox can't drive the install wizard, so the section is
            // hidden from the sidebar. If the user lands here via a
            // stale selection, route them home.
            WelcomeSectionView(store: store)
                .onAppear { store.goToSection(.welcome) }
#else
            OpenClawInstallSectionView(store: store)
#endif
        case .identity:
            IdentitySectionView(store: store)
        case .focus:
            FocusSectionView(store: store)
        case .founderFile:
            FounderFileSectionView(store: store)
        case .toolsAndBridges:
            ToolsAndBridgesSectionView(store: store)
        case .dailyQuestions:
            DailyQuestionsSectionView(store: store)
        case .dataSources:
            DataSourcesSectionView(store: store)
        case .apiKeys:
            APIKeysSectionView(store: store)
        case .preview:
            PreviewAndExportSectionView(store: store)
        }
    }
}
