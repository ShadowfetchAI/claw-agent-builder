import SwiftUI

struct BuilderSidebar: View {
    @Bindable var store: BuilderStore

    private var selection: Binding<BuilderSection?> {
        Binding(
            get: { store.selectedSection },
            set: { newValue in
                if let newValue {
                    store.goToSection(newValue)
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let icon = ModuleArtwork.appIcon.image {
                HStack(spacing: 14) {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(OakPalette.borderStrong, lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("CLAW AGENT BUILDER")
                            .font(.system(.headline, design: .serif, weight: .semibold))
                        Text("OpenClaw agent forge")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            SurfaceCard(title: store.installStatus.readiness.title, icon: "bolt.horizontal.circle") {
                Text(store.installStatus.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            List(selection: selection) {
                ForEach(BuilderSection.visibleCases) { section in
                    let completion = store.sectionCompletion(section)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: section.symbolName)
                                .foregroundStyle(OakPalette.brass)
                                .frame(width: 18)
                            Text(section.title)
                            Spacer()
                            Image(systemName: completion.symbolName)
                                .foregroundStyle(completion == .done ? OakPalette.sage : .secondary)
                                .font(.caption)
                        }
                        Text(section.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                    .tag(section)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [OakPalette.panelTop.opacity(0.95), OakPalette.panelBottom.opacity(0.98)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(OakPalette.borderStrong, lineWidth: 1)
        )
        .shadow(color: OakPalette.shadow, radius: 26, y: 16)
    }
}
