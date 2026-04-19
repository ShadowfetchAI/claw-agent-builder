import SwiftUI

struct FounderFileSectionView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PageGuideCard(section: .founderFile)

            SurfaceCard(title: "Founder file strategy", icon: "person.text.rectangle") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The full founder file stays private as `FOUNDER.md`. A tighter `FOUNDER_PROFILE.md` is what gets injected into the agent worldview.")
                    Toggle("Use founder profile injection", isOn: $store.draft.useFounderProfileInjection)
                    Text("\(store.draft.answeredFounderQuestionsCount) of 50 questions answered so far.")
                        .foregroundStyle(.secondary)
                }
            }

            SurfaceCard(title: "Sections included in the founder profile", icon: "slider.horizontal.3") {
                ForEach(FounderQuestionSection.allCases) { section in
                    Toggle(
                        isOn: Binding(
                            get: { store.summaryIncludesSection(section) },
                            set: { store.setSummarySection(section, enabled: $0) }
                        )
                    ) {
                        Text(section.rawValue)
                    }
                }
            }

            ForEach(FounderQuestionSection.allCases) { section in
                SurfaceCard(title: section.rawValue, icon: "text.bubble") {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(FounderQuestion.all.filter { $0.section == section }) { question in
                            QuestionAnswerCard(question: question, answer: store.founderAnswerBinding(for: question))
                        }
                    }
                }
            }
        }
    }
}
