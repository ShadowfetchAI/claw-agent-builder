import SwiftUI

struct DailyQuestionsSectionView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PageGuideCard(section: .dailyQuestions)

            if let image = ModuleArtwork.gettingToKnowYou.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 520)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            SurfaceCard(title: "Daily getting-to-know-you flow", icon: "heart.text.square") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("This is meant to feel human and gradual, not like a personality harvest. One question a day. Private by default. Slow by design.")
                    Toggle("Enable daily questions", isOn: $store.draft.enableDailyQuestions)
                    Toggle("Private channels only", isOn: $store.draft.privateQuestionsOnly)
                    Toggle("Send one reminder if unanswered", isOn: $store.draft.remindIfUnanswered)
                    Toggle("Allow fallback to the next approved private channel", isOn: $store.draft.allowQuestionFallback)
                    Toggle("Bundle the 1000-question pack in the export", isOn: $store.draft.includeQuestionBank)
                }
            }

            SurfaceCard(title: "Behavior rules", icon: "exclamationmark.shield") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Ask only one question at a time.")
                    Text("• Do not ask in groups or public channels unless the founder explicitly changes that rule.")
                    Text("• If a question is still unanswered, do not keep piling on new ones.")
                    Text("• Promote only durable, useful answers into founder memory.")
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}
