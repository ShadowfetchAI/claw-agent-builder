import SwiftUI

struct PreviewPane: View {
    @Bindable var store: BuilderStore

    var body: some View {
        let files = store.generatedFiles
        let selectedFile = files.first(where: { $0.path == store.selectedPreviewPath }) ?? files.first

        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Generated OpenClaw Files")
                        .font(.system(.title3, design: .serif, weight: .semibold))
                    Text("Review the exact workspace output before you export it.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                OakStatPill(text: "\(files.count) files")
            }

            Picker("Preview file", selection: $store.selectedPreviewPath) {
                ForEach(files) { file in
                    Text(file.path).tag(file.path)
                }
            }
            .pickerStyle(.menu)

            Divider()

            ScrollView {
                if let selectedFile {
                    Text(selectedFile.contents)
                        .font(.system(size: 12.5, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .oakInsetSurface()
                } else {
                    Text("No preview is available yet.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [OakPalette.panelTop.opacity(0.97), OakPalette.panelBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(OakPalette.borderStrong, lineWidth: 1)
        )
        .shadow(color: OakPalette.shadow, radius: 28, y: 18)
    }
}
