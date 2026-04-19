import Foundation

/// A curated starting point that snaps a `BuilderDraft` into a sensible
/// shape for a common use case. We use these as "pick one and refine" —
/// everything is still editable after apply.
///
/// The goal is: someone opens the app, picks a preset that sounds like
/// them, and is 80% of the way to a real workspace without reading a
/// manual.
struct AgentPreset: Identifiable, Hashable {
    let id: String
    let title: String
    let tagline: String
    let symbolName: String
    let apply: @Sendable (inout BuilderDraft) -> Void

    static func == (lhs: AgentPreset, rhs: AgentPreset) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum AgentPresets {
    static let all: [AgentPreset] = [
        founderCopilot,
        operatorAgent,
        researchAgent,
        socialAgent,
        builderCoder,
        supportAgent
    ]

    // MARK: - Concrete presets

    static let founderCopilot = AgentPreset(
        id: "founder-copilot",
        title: "Founder Copilot",
        tagline: "Default choice. Decision support, memos, memory, and judgment.",
        symbolName: "sparkles",
        apply: { draft in
            draft.buildMode = .newMainAgent
            draft.agentName = "Harbor"
            draft.nickname = "Harbor"
            draft.creature = "Lobster"
            draft.emoji = "🦞"
            draft.archetype = "Founder-side operator"
            draft.primaryFocus = .founderCopilot
            draft.secondaryFocuses = [.operations, .research]
            draft.selectedJobs = [
                .prioritizeWork, .draftStrategyMemos, .maintainWorkspaceMemory, .askDailyQuestions
            ]
            draft.selectedChannels = [.controlUI, .whatsapp]
            draft.selectedBridges = [.browserSearch, .githubOps, .localScripts]
            draft.selectedAPIs = [.nationalWeatherService, .openMeteo, .nasa, .usgs]
            draft.enableDailyQuestions = true
        }
    )

    static let operatorAgent = AgentPreset(
        id: "operator",
        title: "Operator",
        tagline: "Runs the systems. Watches recurring tasks and surfaces misses.",
        symbolName: "gearshape.2",
        apply: { draft in
            draft.buildMode = .newIsolatedAgent
            draft.agentName = "Pulse"
            draft.nickname = "Pulse"
            draft.creature = "Heron"
            draft.emoji = "🦩"
            draft.archetype = "Operational watchkeeper"
            draft.primaryFocus = .operations
            draft.secondaryFocuses = [.archive]
            draft.selectedJobs = [.manageSystems, .watchRecurringTasks, .maintainWorkspaceMemory]
            draft.selectedChannels = [.controlUI]
            draft.selectedBridges = [.localScripts, .browserSearch]
            draft.selectedAPIs = [.nationalWeatherService, .usgs]
            draft.enableDailyQuestions = false
        }
    )

    static let researchAgent = AgentPreset(
        id: "research",
        title: "Research Agent",
        tagline: "Source-backed research, comparisons, synthesis.",
        symbolName: "magnifyingglass.circle",
        apply: { draft in
            draft.buildMode = .newIsolatedAgent
            draft.agentName = "Atlas"
            draft.nickname = "Atlas"
            draft.creature = "Owl"
            draft.emoji = "🦉"
            draft.archetype = "Research lead"
            draft.primaryFocus = .research
            draft.secondaryFocuses = [.news, .archive]
            draft.selectedJobs = [.researchOptions, .summarizeSources, .maintainWorkspaceMemory]
            draft.selectedChannels = [.controlUI, .telegram]
            draft.selectedBridges = [.browserSearch, .newsBot, .scrapeBot, .archiveBot]
            draft.selectedAPIs = [.worldBank, .fred, .nasa, .usgs]
            draft.enableDailyQuestions = false
        }
    )

    static let socialAgent = AgentPreset(
        id: "social",
        title: "Social Agent",
        tagline: "Voice-aware drafting and approval gates before anything ships.",
        symbolName: "megaphone",
        apply: { draft in
            draft.buildMode = .newIsolatedAgent
            draft.agentName = "Echo"
            draft.nickname = "Echo"
            draft.creature = "Mockingbird"
            draft.emoji = "🐦"
            draft.archetype = "Social drafter with taste"
            draft.primaryFocus = .social
            draft.secondaryFocuses = [.media, .support]
            draft.selectedJobs = [.draftPublicContent, .reviewOutputs, .draftFollowUps]
            draft.selectedChannels = [.controlUI, .whatsapp, .blueBubbles]
            draft.selectedBridges = [.browserSearch]
            draft.selectedAPIs = []
            draft.enableDailyQuestions = true
        }
    )

    static let builderCoder = AgentPreset(
        id: "builder-coder",
        title: "Builder / Coder",
        tagline: "Scaffolds projects, helps debug real builds, ships code.",
        symbolName: "hammer",
        apply: { draft in
            draft.buildMode = .newIsolatedAgent
            draft.agentName = "Forge"
            draft.nickname = "Forge"
            draft.creature = "Mantis"
            draft.emoji = "🛠"
            draft.archetype = "Engineering pair"
            draft.primaryFocus = .builderCoder
            draft.secondaryFocuses = [.research, .operations]
            draft.selectedJobs = [.scaffoldProjects, .debugBuilds, .maintainWorkspaceMemory]
            draft.selectedChannels = [.controlUI]
            draft.selectedBridges = [.githubOps, .localScripts, .browserSearch]
            draft.selectedAPIs = []
            draft.enableDailyQuestions = false
        }
    )

    static let supportAgent = AgentPreset(
        id: "support",
        title: "Support Agent",
        tagline: "Warm, clear, calm responses for real users.",
        symbolName: "lifepreserver",
        apply: { draft in
            draft.buildMode = .newIsolatedAgent
            draft.agentName = "Cove"
            draft.nickname = "Cove"
            draft.creature = "Otter"
            draft.emoji = "🦦"
            draft.archetype = "Support first-responder"
            draft.primaryFocus = .support
            draft.secondaryFocuses = [.crm]
            draft.selectedJobs = [.draftFollowUps, .reviewOutputs]
            draft.selectedChannels = [.controlUI, .whatsapp, .telegram]
            draft.selectedBridges = [.browserSearch]
            draft.selectedAPIs = []
            draft.enableDailyQuestions = false
        }
    )
}
