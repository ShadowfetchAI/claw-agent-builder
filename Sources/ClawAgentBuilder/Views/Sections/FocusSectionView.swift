import SwiftUI

struct FocusSectionView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PageGuideCard(section: .focus)

            SurfaceCard(title: "Build mode", icon: "square.stack.3d.up") {
                Picker("Build mode", selection: $store.draft.buildMode) {
                    ForEach(BuildMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }

                Text(store.draft.buildMode.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }

            SurfaceCard(title: "Primary focus", icon: "scope") {
                Picker("Primary focus", selection: $store.draft.primaryFocus) {
                    ForEach(FocusPack.allCases) { focus in
                        Text(focus.title).tag(focus)
                    }
                }

                Text(store.draft.primaryFocus.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                Button("Use recommended jobs for \(store.draft.primaryFocus.title)") {
                    store.applyPrimaryFocusRecommendations()
                }
                .padding(.top, 8)
            }

            SurfaceCard(title: "Secondary focuses", icon: "plus.circle.on.circle") {
                ForEach(FocusPack.allCases.filter { $0 != store.draft.primaryFocus }) { focus in
                    Toggle(
                        isOn: Binding(
                            get: { store.containsSecondaryFocus(focus) },
                            set: { store.setSecondaryFocus(focus, enabled: $0) }
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(focus.title)
                            Text(focus.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            SurfaceCard(title: "What jobs will this agent do?", icon: "checklist") {
                ForEach(JobOption.allCases) { job in
                    Toggle(
                        isOn: Binding(
                            get: { store.containsJob(job) },
                            set: { store.setJob(job, enabled: $0) }
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(job.title)
                            Text(job.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
