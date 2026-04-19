import SwiftUI

struct ToolsAndBridgesSectionView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PageGuideCard(section: .toolsAndBridges)

            SurfaceCard(title: "Approved private channels", icon: "message.badge") {
                ForEach(ChannelOption.allCases) { channel in
                    Toggle(
                        isOn: Binding(
                            get: { store.containsChannel(channel) },
                            set: { store.setChannel(channel, enabled: $0) }
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(channel.title)
                            Text(channel.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            SurfaceCard(title: "Bridge packs", icon: "point.bottomleft.forward.to.point.topright.scurvepath") {
                ForEach(BridgePack.allCases) { bridge in
                    Toggle(
                        isOn: Binding(
                            get: { store.containsBridge(bridge) },
                            set: { store.setBridge(bridge, enabled: $0) }
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(bridge.title)
                            Text(bridge.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            SurfaceCard(title: "Bridge notes", icon: "note.text") {
                TextEditor(text: $store.draft.bridgeNotes)
                    .frame(minHeight: 140)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text("Use this for bridge paths, dry-run cautions, or install notes you want embedded in TOOLS.md.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
