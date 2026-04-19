import SwiftUI

struct DataSourcesSectionView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PageGuideCard(section: .dataSources)

            SurfaceCard(title: "Durable public data sources", icon: "antenna.radiowaves.left.and.right") {
                Text("These are the smaller, more durable APIs worth exposing in V1: weather, science, macro data, and public institutions that should be around for a long time.")
                    .foregroundStyle(.secondary)
            }

            ForEach(ApiCatalogItem.allCases) { api in
                SurfaceCard(title: api.title, icon: "network") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(
                            isOn: Binding(
                                get: { store.containsAPI(api) },
                                set: { store.setAPI(api, enabled: $0) }
                            )
                        ) {
                            Text("Include in exported API catalog")
                        }

                        Text(api.summary)
                        Text("Access: \(api.accessType.rawValue)")
                            .foregroundStyle(.secondary)
                        Text(api.setupNote)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let docsURL = URL(string: api.docsURL) {
                            Link("Open docs", destination: docsURL)
                        }
                    }
                }
            }
        }
    }
}
