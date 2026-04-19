import SwiftUI

struct IdentitySectionView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PageGuideCard(section: .identity)

            SurfaceCard(title: "Agent naming", icon: "signature") {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Agent name", text: $store.draft.agentName)
                    TextField("Nickname", text: $store.draft.nickname)
                    HStack {
                        TextField("Emoji", text: $store.draft.emoji)
                            .frame(maxWidth: 120)
                        TextField("Creature / metaphor", text: $store.draft.creature)
                    }
                    TextField("Archetype", text: $store.draft.archetype)
                    TextField("Vibe", text: $store.draft.vibe)
                    TextField("One-sentence description", text: $store.draft.agentDescription, axis: .vertical)
                }
            }

            SurfaceCard(title: "Identity preview", icon: "person.crop.square") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(store.draft.agentName) \(store.draft.emoji)")
                        .font(.title2.weight(.semibold))
                    Text(store.draft.agentDescription)
                    Text("Slug: \(store.draft.agentSlug)")
                        .foregroundStyle(.secondary)
                    Text("This slug is what I’ll use for export naming and isolated-agent suggestions.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            SurfaceCard(title: "User relationship", icon: "person.2") {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Founder / user name", text: Binding(
                        get: { store.draft.userName },
                        set: { newValue in
                            let previous = store.draft.userName.trimmingCharacters(in: .whitespacesAndNewlines)
                            store.draft.userName = newValue

                            // Smart-fill: if founder-questionnaire Q1
                            // ("What is your full name?") is blank or
                            // still mirrors the previous value, copy
                            // the name forward so the user doesn't feel
                            // they are retyping the same thing twice.
                            let current = store.draft.founderAnswers[1]?
                                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            let trimmedNew = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            if (current.isEmpty || current == previous) && !trimmedNew.isEmpty {
                                store.draft.founderAnswers[1] = newValue
                            }
                        }
                    ))
                    TextField("Preferred call sign", text: $store.draft.userCallSign)
                    TextField("Private communication style", text: $store.draft.communicationStyle, axis: .vertical)
                    TextField("Public-facing voice", text: $store.draft.publicVoice, axis: .vertical)
                    TextField("Approval rules", text: $store.draft.approvalStyle, axis: .vertical)
                }
            }
        }
    }
}
