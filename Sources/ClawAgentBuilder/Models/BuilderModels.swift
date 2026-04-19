import Foundation

/// State of a given section relative to the current draft. Drives
/// the sidebar indicators and the "next step" suggestion footer so a
/// first-time user always knows where to look next.
enum SectionCompletion {
    case notStarted
    case inProgress
    case done

    var symbolName: String {
        switch self {
        case .notStarted: return "circle.dashed"
        case .inProgress: return "circle.lefthalf.filled"
        case .done: return "checkmark.circle.fill"
        }
    }
}

enum BuilderSection: String, CaseIterable, Identifiable {
    case welcome
    case openClawInstall
    case identity
    case focus
    case founderFile
    case toolsAndBridges
    case dailyQuestions
    case dataSources
    case apiKeys
    case preview

    var id: String { rawValue }

    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .openClawInstall:
            return "Install OpenClaw"
        case .identity:
            return "Agent Identity"
        case .focus:
            return "Focus"
        case .founderFile:
            return "Founder File"
        case .toolsAndBridges:
            return "Tools + Bridges"
        case .dailyQuestions:
            return "Getting To Know You"
        case .dataSources:
            return "Data Sources"
        case .apiKeys:
            return "API Keys & Providers"
        case .preview:
            return "Preview + Export"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome:
            return "Build a real OpenClaw agent workspace, not a generic AI profile."
        case .openClawInstall:
            return "OpenClaw is the engine. This app is the forge that shapes it."
        case .identity:
            return "Name the agent, shape its vibe, and give it an identity worth keeping."
        case .focus:
            return "Choose what jobs this agent should actually do in the world."
        case .founderFile:
            return "Capture the founder's style, instincts, values, and long-term vision."
        case .toolsAndBridges:
            return "Map the agent onto the channels, bridges, and skills it will really use."
        case .dailyQuestions:
            return "Let the agent learn one thoughtful thing at a time in approved private chats."
        case .dataSources:
            return "Attach durable information sources the agent can rely on for years."
        case .apiKeys:
            return "Pick your model provider and channel bridges, paste keys, done."
        case .preview:
            return "Generate the workspace, review the files, and export a complete package."
        }
    }

    var pageLead: String {
        switch self {
        case .welcome:
            return "This builder follows the real OpenClaw flow in plain English, then helps you shape a better agent without making you learn the workspace format first."
        case .openClawInstall:
            return "This page checks whether OpenClaw is already on the Mac, then walks you through the official install and onboarding steps in the safest order."
        case .identity:
            return "This is where you decide who the agent is, what it should be called, and how it should relate to the founder it serves."
        case .focus:
            return "This page sets the actual work the agent is meant to do so later files, defaults, and skills all point in the same direction."
        case .founderFile:
            return "This page captures the founder's style and worldview so the agent can feel aligned instead of generic."
        case .toolsAndBridges:
            return "This is where you choose the channels, bridge packs, and tool posture the agent is allowed to use in the real world."
        case .dailyQuestions:
            return "This page controls the slow getting-to-know-you loop so the agent can learn over time without becoming intrusive."
        case .dataSources:
            return "This page lets you bundle durable public information sources the agent can lean on for weather, science, economic data, and more."
        case .apiKeys:
            return "This is the plain-language key and provider step, so you can choose models and bridge credentials without hand-editing shell files."
        case .preview:
            return "This final page shows what will be written, where it will go, and gives you a safe export or install path."
        }
    }

    var pageSteps: [String] {
        switch self {
        case .welcome:
            return [
                "Pick a starting preset so the app can fill in sane defaults for the kind of agent you want.",
                "Read the step-by-step path so you know exactly what the app will ask you next.",
                "Move forward one section at a time — nothing here locks you in, and you can retune the agent later."
            ]
        case .openClawInstall:
            return [
                "Check whether OpenClaw is already installed and whether onboarding was already completed on this Mac.",
                "If needed, run the official install and onboarding commands with guided help instead of guessing.",
                "Come back here any time to re-check status before doing a live install."
            ]
        case .identity:
            return [
                "Name the agent and give it a clear identity, vibe, and working relationship to the founder.",
                "Set the human-facing tone so the generated files feel intentional instead of default.",
                "Review the live slug preview because that name is used for exports and isolated-agent suggestions."
            ]
        case .focus:
            return [
                "Choose whether this is a main agent, isolated agent, retune, or remote package.",
                "Set the primary focus that best matches the agent's real job.",
                "Add secondary focuses and concrete jobs so the workspace is tuned for actual work, not vague personality."
            ]
        case .founderFile:
            return [
                "Answer as many founder questions as you want — the full answers stay in `FOUNDER.md`.",
                "Choose which sections should shape the injected founder profile.",
                "Build a sharper founder summary without forcing every private detail into runtime context."
            ]
        case .toolsAndBridges:
            return [
                "Choose which private channels the agent is allowed to use.",
                "Turn on only the bridge packs that match the work you really want the agent doing.",
                "Leave notes for paths, warnings, and install details that should land in `TOOLS.md`."
            ]
        case .dailyQuestions:
            return [
                "Decide whether the agent should ask one getting-to-know-you question per day.",
                "Set guardrails so those questions stay private, patient, and non-spammy.",
                "Bundle the question pack only if you want that personality-building loop in the exported workspace."
            ]
        case .dataSources:
            return [
                "Pick the durable public APIs you want the agent to know about.",
                "Keep the list small and practical so the generated workspace stays focused.",
                "Use this as a catalog step, not a key step — credentials come later on the API page."
            ]
        case .apiKeys:
            return [
                "Turn on only the providers and bridges you actually plan to use.",
                "Paste keys into the secure fields so the builder can generate a clean `.env.example` file.",
                "Decide whether the export should contain only placeholder env names or the real secrets you typed."
            ]
        case .preview:
            return [
                "Review the generated files and confirm the package matches the agent you intended to build.",
                "Choose whether to export safely to the Desktop, install into the main workspace, or create an isolated workspace.",
                "Save a draft if you want to come back and retune the same agent later."
            ]
        }
    }

    var pageWhyItMatters: String {
        switch self {
        case .welcome:
            return "Beginners get confused when a builder feels like a control panel. This first page is here to establish the path before the app asks you for real decisions."
        case .openClawInstall:
            return "OpenClaw owns the engine. If install status is unclear, everything later feels risky and confusing."
        case .identity:
            return "A strong agent identity keeps the workspace coherent and makes later tuning decisions easier."
        case .focus:
            return "Focus determines the shape of the generated files, the jobs list, the bridge posture, and the defaults the app recommends."
        case .founderFile:
            return "Founder context is what makes the agent feel personal and aligned instead of like a generic assistant wearing a new name tag."
        case .toolsAndBridges:
            return "Choosing tools carelessly makes an agent noisy or risky. This page sets the real-world boundaries."
        case .dailyQuestions:
            return "The daily-question system should build trust, not invade privacy. These rules are what keep it helpful."
        case .dataSources:
            return "Durable public data sources give the agent useful external context without forcing you into unstable or obscure APIs."
        case .apiKeys:
            return "This step translates provider choices into a clean, repeatable env file so you are not hunting through terminal docs later."
        case .preview:
            return "This is the last chance to verify the package before anything is written into a live OpenClaw workspace."
        }
    }

    var pageNextHint: String {
        switch self {
        case .welcome:
            return "Next, the app checks or installs OpenClaw so the rest of the build has a real runtime to land on."
        case .openClawInstall:
            return "Once install is clear, the next step is naming the agent and defining the relationship."
        case .identity:
            return "After identity, you'll decide what jobs and focus this agent should have."
        case .focus:
            return "Next comes founder context so the agent can start thinking in the right voice and priorities."
        case .founderFile:
            return "After founder context, you'll choose the tools, bridges, and channels the agent can use."
        case .toolsAndBridges:
            return "Next you'll decide whether the agent should slowly learn the founder through daily questions."
        case .dailyQuestions:
            return "After behavior is set, the next step is choosing durable outside data sources."
        case .dataSources:
            return "Next you'll add the model and bridge keys needed to make the generated package actually run."
        case .apiKeys:
            return "The final step is previewing the files and deciding where to export or install them."
        case .preview:
            return "When this page looks right, export safely or install into the target workspace you chose."
        }
    }

    var symbolName: String {
        switch self {
        case .welcome:
            return "sparkles.rectangle.stack"
        case .openClawInstall:
            return "shippingbox"
        case .identity:
            return "person.crop.square.filled.and.at.rectangle"
        case .focus:
            return "scope"
        case .founderFile:
            return "person.text.rectangle"
        case .toolsAndBridges:
            return "square.stack.3d.up"
        case .dailyQuestions:
            return "message.badge.waveform"
        case .dataSources:
            return "network.badge.shield.half.filled"
        case .apiKeys:
            return "key.horizontal"
        case .preview:
            return "doc.text.magnifyingglass"
        }
    }

    /// The next section the user should probably look at. Used by the
    /// Sections visible in the current build flavor. The App Store
    /// edition hides the OpenClaw install wizard (sandbox can't drive
    /// shell/AppleScript) — the user installs OpenClaw themselves and
    /// comes to this app to generate workspace files.
    static var visibleCases: [BuilderSection] {
        allCases.filter { $0.isAvailableInCurrentFlavor }
    }

    /// Per-flavor availability. Kept as a computed property so logic
    /// that walks `allCases` (tests, admin tooling) still works.
    var isAvailableInCurrentFlavor: Bool {
        switch self {
        case .openClawInstall:
            return !BuildFlavor.isAppStore
        default:
            return true
        }
    }

    /// "Next step" button in the shared section footer so first-time
    /// users always have a nudge toward forward motion. Skips sections
    /// that are hidden in the current flavor.
    var next: BuilderSection? {
        let all = BuilderSection.visibleCases
        guard let idx = all.firstIndex(of: self), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }

    var previous: BuilderSection? {
        let all = BuilderSection.visibleCases
        guard let idx = all.firstIndex(of: self), idx > 0 else { return nil }
        return all[idx - 1]
    }

    var stepNumber: Int {
        (BuilderSection.visibleCases.firstIndex(of: self) ?? 0) + 1
    }

    /// Lightweight heuristic to decide whether the user has given this
    /// section enough attention to consider it "done" for progress
    /// display. Intentionally forgiving — it's a nudge, not a gate.
    func completion(for draft: BuilderDraft) -> SectionCompletion {
        switch self {
        case .welcome:
            return .done  // nothing to fill in, always considered done
        case .openClawInstall:
            return .notStarted  // drives off install status elsewhere
        case .identity:
            let named = !draft.agentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let customized = draft.agentName != "Harbor" || draft.nickname != "Harbor"
            if !named { return .notStarted }
            return customized ? .done : .inProgress
        case .focus:
            return draft.selectedJobs.isEmpty ? .notStarted : .done
        case .founderFile:
            let answered = draft.answeredFounderQuestionsCount
            if answered == 0 { return .notStarted }
            return answered >= 10 ? .done : .inProgress
        case .toolsAndBridges:
            return draft.selectedChannels.isEmpty && draft.selectedBridges.isEmpty ? .notStarted : .done
        case .dailyQuestions:
            return draft.enableDailyQuestions ? .done : .inProgress
        case .dataSources:
            return draft.selectedAPIs.isEmpty ? .inProgress : .done
        case .apiKeys:
            return draft.enabledProviderIDs.isEmpty ? .notStarted : .done
        case .preview:
            return .inProgress
        }
    }
}

/// Which lane the user chose on the Welcome page. Lets us skip the
/// install step for people who already have OpenClaw running and just
/// want the agent files refreshed.
enum StartingPath: String, CaseIterable, Codable, Identifiable, Hashable {
    case existingOpenClaw
    case fullInstall

    var id: String { rawValue }

    var title: String {
        switch self {
        case .existingOpenClaw:
            return "I already have OpenClaw"
        case .fullInstall:
            return "Install OpenClaw + build my agent"
        }
    }

    var tagline: String {
        switch self {
        case .existingOpenClaw:
            return "Skip the install step. Just generate tuned agent files and drop them into my existing ~/.openclaw/workspace (with automatic backup)."
        case .fullInstall:
            return "I'm starting from zero. Walk me through the official OpenClaw install, onboarding, and then lay down my tuned workspace."
        }
    }

    var symbolName: String {
        switch self {
        case .existingOpenClaw: return "folder.badge.person.crop"
        case .fullInstall: return "shippingbox.and.arrow.backward"
        }
    }
}

enum BuildMode: String, CaseIterable, Codable, Identifiable {
    case newMainAgent
    case newIsolatedAgent
    case retuneExistingAgent
    case remotePackage

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newMainAgent:
            return "Build New Main Agent"
        case .newIsolatedAgent:
            return "Build New Isolated Agent"
        case .retuneExistingAgent:
            return "Retune Existing Agent"
        case .remotePackage:
            return "Remote Package Build"
        }
    }

    var summary: String {
        switch self {
        case .newMainAgent:
            return "Targets the default ~/.openclaw/workspace path."
        case .newIsolatedAgent:
            return "Creates a separate personality and workspace for a named OpenClaw agent."
        case .retuneExistingAgent:
            return "Rebuilds selected files while keeping the rest of the workspace intact."
        case .remotePackage:
            return "Exports a ready-to-copy package for a remote gateway host."
        }
    }
}

enum FocusPack: String, CaseIterable, Codable, Identifiable, Hashable {
    case founderCopilot
    case operations
    case research
    case builderCoder
    case social
    case crm
    case archive
    case news
    case support
    case media

    var id: String { rawValue }

    var title: String {
        switch self {
        case .founderCopilot:
            return "Founder Copilot"
        case .operations:
            return "Operator"
        case .research:
            return "Research Agent"
        case .builderCoder:
            return "Builder / Coder"
        case .social:
            return "Social Agent"
        case .crm:
            return "CRM Agent"
        case .archive:
            return "Archive Agent"
        case .news:
            return "News Agent"
        case .support:
            return "Support Agent"
        case .media:
            return "Media / Meme Agent"
        }
    }

    var summary: String {
        switch self {
        case .founderCopilot:
            return "Decision support, memo drafting, memory, founder alignment, and judgment."
        case .operations:
            return "Recurring tasks, system hygiene, bridge awareness, and execution discipline."
        case .research:
            return "Source-backed research, comparisons, evidence logging, and synthesis."
        case .builderCoder:
            return "Project scaffolding, coding help, technical debugging, and shipping."
        case .social:
            return "Voice-aware drafting, social review, approval gates, and publishing discipline."
        case .crm:
            return "Follow-ups, relationships, customer notes, and warm outreach."
        case .archive:
            return "Memory upkeep, summaries, consolidation, and durable context."
        case .news:
            return "Topic watches, candidate triage, trend briefings, and signal surfacing."
        case .support:
            return "User help, issue clarity, response drafting, and calm resolution."
        case .media:
            return "Visual ideas, meme flows, prompt packs, and asset handling."
        }
    }

    var recommendedJobs: Set<JobOption> {
        switch self {
        case .founderCopilot:
            return [.prioritizeWork, .draftStrategyMemos, .maintainWorkspaceMemory, .askDailyQuestions]
        case .operations:
            return [.manageSystems, .watchRecurringTasks, .maintainWorkspaceMemory]
        case .research:
            return [.researchOptions, .summarizeSources, .maintainWorkspaceMemory]
        case .builderCoder:
            return [.scaffoldProjects, .debugBuilds, .maintainWorkspaceMemory]
        case .social:
            return [.draftPublicContent, .reviewOutputs]
        case .crm:
            return [.maintainWorkspaceMemory, .draftFollowUps]
        case .archive:
            return [.maintainWorkspaceMemory, .summarizeSources]
        case .news:
            return [.monitorTrends, .summarizeSources]
        case .support:
            return [.draftFollowUps, .reviewOutputs]
        case .media:
            return [.draftPublicContent, .reviewOutputs]
        }
    }
}

enum JobOption: String, CaseIterable, Codable, Identifiable, Hashable {
    case prioritizeWork
    case draftStrategyMemos
    case maintainWorkspaceMemory
    case askDailyQuestions
    case manageSystems
    case watchRecurringTasks
    case researchOptions
    case summarizeSources
    case scaffoldProjects
    case debugBuilds
    case draftPublicContent
    case reviewOutputs
    case draftFollowUps
    case monitorTrends

    var id: String { rawValue }

    var title: String {
        switch self {
        case .prioritizeWork:
            return "Prioritize work"
        case .draftStrategyMemos:
            return "Draft strategy memos"
        case .maintainWorkspaceMemory:
            return "Maintain workspace memory"
        case .askDailyQuestions:
            return "Ask daily personality questions"
        case .manageSystems:
            return "Manage systems"
        case .watchRecurringTasks:
            return "Watch recurring tasks"
        case .researchOptions:
            return "Research options"
        case .summarizeSources:
            return "Summarize sources"
        case .scaffoldProjects:
            return "Scaffold projects"
        case .debugBuilds:
            return "Debug builds"
        case .draftPublicContent:
            return "Draft public content"
        case .reviewOutputs:
            return "Review outputs"
        case .draftFollowUps:
            return "Draft follow-ups"
        case .monitorTrends:
            return "Monitor trends"
        }
    }

    var summary: String {
        switch self {
        case .prioritizeWork:
            return "Sort what matters right now and what can wait."
        case .draftStrategyMemos:
            return "Turn thinking into structured plans and founder-ready memos."
        case .maintainWorkspaceMemory:
            return "Promote the right facts into durable AGENTS/MEMORY context."
        case .askDailyQuestions:
            return "Learn one new thing at a time through private daily prompts."
        case .manageSystems:
            return "Watch health, logs, and operational state."
        case .watchRecurringTasks:
            return "Track repeating duties and surface misses early."
        case .researchOptions:
            return "Gather sources, compare paths, and explain tradeoffs."
        case .summarizeSources:
            return "Condense external information into something the founder can use."
        case .scaffoldProjects:
            return "Lay down folders, files, and starter implementations."
        case .debugBuilds:
            return "Work through real compiler, runtime, and packaging failures."
        case .draftPublicContent:
            return "Generate drafts for posts, updates, and launch copy."
        case .reviewOutputs:
            return "Act as a skeptical editor before anything ships."
        case .draftFollowUps:
            return "Write warm, useful follow-ups for users, leads, or collaborators."
        case .monitorTrends:
            return "Watch topics and surface what actually matters."
        }
    }
}

enum ChannelOption: String, CaseIterable, Codable, Identifiable, Hashable {
    case controlUI
    case whatsapp
    case blueBubbles
    case telegram
    case discord

    var id: String { rawValue }

    var title: String {
        switch self {
        case .controlUI:
            return "OpenClaw Control UI"
        case .whatsapp:
            return "WhatsApp"
        case .blueBubbles:
            return "iMessage via BlueBubbles"
        case .telegram:
            return "Telegram"
        case .discord:
            return "Discord DM"
        }
    }

    var summary: String {
        switch self {
        case .controlUI:
            return "Fastest first chat and easiest safe fallback surface."
        case .whatsapp:
            return "Strong private-first channel if already part of the founder workflow."
        case .blueBubbles:
            return "Bridges the iMessage lane through BlueBubbles."
        case .telegram:
            return "One of the quickest official channel setups."
        case .discord:
            return "Useful for private DMs, not public server spraying."
        }
    }
}

enum BridgePack: String, CaseIterable, Codable, Identifiable, Hashable {
    case browserSearch
    case githubOps
    case localScripts
    case archiveBot
    case newsBot
    case scrapeBot
    case blueBubblesBridge
    case whatsappBridge

    var id: String { rawValue }

    var title: String {
        switch self {
        case .browserSearch:
            return "Browser + Search"
        case .githubOps:
            return "GitHub Ops"
        case .localScripts:
            return "Local Scripts"
        case .archiveBot:
            return "ArchiveBot"
        case .newsBot:
            return "NewsBot"
        case .scrapeBot:
            return "ScrapeBot"
        case .blueBubblesBridge:
            return "BlueBubbles Bridge"
        case .whatsappBridge:
            return "WhatsApp Bridge"
        }
    }

    var summary: String {
        switch self {
        case .browserSearch:
            return "Web research and source-backed retrieval."
        case .githubOps:
            return "PR review, issue work, and repository awareness."
        case .localScripts:
            return "Custom scripts that live alongside the workspace."
        case .archiveBot:
            return "Archival capture and library retrieval."
        case .newsBot:
            return "Topic monitoring and headline triage."
        case .scrapeBot:
            return "Structured extraction from trusted web surfaces."
        case .blueBubblesBridge:
            return "Direct iMessage reach through BlueBubbles."
        case .whatsappBridge:
            return "Private WhatsApp routing and follow-up delivery."
        }
    }
}

enum APIAccessType: String, Codable {
    case keyless = "Works now"
    case freeSignup = "Free with signup"
}

enum ApiCatalogItem: String, CaseIterable, Codable, Identifiable, Hashable {
    case nationalWeatherService
    case openMeteo
    case nasa
    case usgs
    case worldBank
    case fred

    var id: String { rawValue }

    var title: String {
        switch self {
        case .nationalWeatherService:
            return "National Weather Service API"
        case .openMeteo:
            return "Open-Meteo"
        case .nasa:
            return "NASA APIs"
        case .usgs:
            return "USGS APIs"
        case .worldBank:
            return "World Bank Indicators API"
        case .fred:
            return "FRED"
        }
    }

    var summary: String {
        switch self {
        case .nationalWeatherService:
            return "Official NOAA/NWS forecasts and alerts for U.S.-focused agents."
        case .openMeteo:
            return "Clean global weather coverage without account friction."
        case .nasa:
            return "Durable science, astronomy, Mars, imagery, and public-data endpoints."
        case .usgs:
            return "Earthquake, water, geology, and real-world event data."
        case .worldBank:
            return "Long-lived country and development indicators."
        case .fred:
            return "St. Louis Fed macroeconomic and financial data."
        }
    }

    var accessType: APIAccessType {
        switch self {
        case .nationalWeatherService, .openMeteo, .usgs, .worldBank:
            return .keyless
        case .nasa, .fred:
            return .freeSignup
        }
    }

    var environmentKey: String? {
        switch self {
        case .nasa:
            return "NASA_API_KEY"
        case .fred:
            return "FRED_API_KEY"
        default:
            return nil
        }
    }

    var docsURL: String {
        switch self {
        case .nationalWeatherService:
            return "https://www.weather.gov/documentation/standards/services-web-api"
        case .openMeteo:
            return "https://open-meteo.com/"
        case .nasa:
            return "https://api.nasa.gov/"
        case .usgs:
            return "https://www.usgs.gov/faqs/does-usgs-have-apis"
        case .worldBank:
            return "https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation"
        case .fred:
            return "https://fred.stlouisfed.org/docs/api/api_key.html"
        }
    }

    var setupNote: String {
        switch self {
        case .nationalWeatherService:
            return "No key required. Best for U.S. forecasts and alerts."
        case .openMeteo:
            return "No key required. Best for global weather."
        case .nasa:
            return "Use DEMO_KEY for quick exploration, but create a personal key for real use."
        case .usgs:
            return "No key required. Great for earthquakes, water, and geology."
        case .worldBank:
            return "No key required. Excellent for country indicators and macro development data."
        case .fred:
            return "Free API key required. Strong choice for U.S. macroeconomic data."
        }
    }
}

enum FounderQuestionSection: String, CaseIterable, Codable, Identifiable, Hashable {
    case basicIdentity = "Basic Identity"
    case background = "Background and Personal Story"
    case personality = "Personality and Identity"
    case communication = "Communication and Relationships"
    case workStyle = "Work Style and Decision-Making"
    case values = "Values, Ambition, and Vision"

    var id: String { rawValue }
}

struct FounderQuestion: Identifiable, Hashable, Codable {
    let number: Int
    let section: FounderQuestionSection
    let prompt: String

    var id: Int { number }

    static let all: [FounderQuestion] = [
        .init(number: 1, section: .basicIdentity, prompt: "What is your full name?"),
        .init(number: 2, section: .basicIdentity, prompt: "What name do you usually go by?"),
        .init(number: 3, section: .basicIdentity, prompt: "What is your date of birth?"),
        .init(number: 4, section: .basicIdentity, prompt: "Where were you born?"),
        .init(number: 5, section: .basicIdentity, prompt: "Where did you grow up?"),
        .init(number: 6, section: .basicIdentity, prompt: "Where do you live now?"),
        .init(number: 7, section: .basicIdentity, prompt: "What do you do professionally right now?"),
        .init(number: 8, section: .basicIdentity, prompt: "What company, project, or brand are you most focused on today?"),
        .init(number: 9, section: .basicIdentity, prompt: "How would you describe yourself in one sentence?"),
        .init(number: 10, section: .basicIdentity, prompt: "How would close friends describe you in one sentence?"),
        .init(number: 11, section: .background, prompt: "What was your childhood environment like?"),
        .init(number: 12, section: .background, prompt: "What kind of family or home culture shaped you most?"),
        .init(number: 13, section: .background, prompt: "What early experiences influenced the way you think?"),
        .init(number: 14, section: .background, prompt: "What were you like as a teenager?"),
        .init(number: 15, section: .background, prompt: "What did you care about most when you were younger?"),
        .init(number: 16, section: .background, prompt: "What were your earliest interests, obsessions, or hobbies?"),
        .init(number: 17, section: .background, prompt: "What kinds of people influenced you most growing up?"),
        .init(number: 18, section: .background, prompt: "What major turning points changed your life?"),
        .init(number: 19, section: .background, prompt: "What failures or setbacks shaped you the most?"),
        .init(number: 20, section: .background, prompt: "What achievements are you proudest of so far?"),
        .init(number: 21, section: .personality, prompt: "What are your strongest personality traits?"),
        .init(number: 22, section: .personality, prompt: "What traits do you wish people understood better about you?"),
        .init(number: 23, section: .personality, prompt: "What are your biggest strengths in work and life?"),
        .init(number: 24, section: .personality, prompt: "What are your biggest weaknesses or blind spots?"),
        .init(number: 25, section: .personality, prompt: "What gives you energy?"),
        .init(number: 26, section: .personality, prompt: "What drains your energy?"),
        .init(number: 27, section: .personality, prompt: "What makes you feel confident?"),
        .init(number: 28, section: .personality, prompt: "What makes you feel misunderstood?"),
        .init(number: 29, section: .personality, prompt: "What situations bring out the best version of you?"),
        .init(number: 30, section: .personality, prompt: "What situations bring out the worst version of you?"),
        .init(number: 31, section: .communication, prompt: "How do you naturally communicate with people?"),
        .init(number: 32, section: .communication, prompt: "How do you prefer other people communicate with you?"),
        .init(number: 33, section: .communication, prompt: "What tone do you like in private conversations?"),
        .init(number: 34, section: .communication, prompt: "What tone do you like in public-facing communication?"),
        .init(number: 35, section: .communication, prompt: "What kinds of language, phrases, or behaviors instantly annoy you?"),
        .init(number: 36, section: .communication, prompt: "What kinds of language, tone, or behavior make you trust someone?"),
        .init(number: 37, section: .communication, prompt: "How do you act when you like and respect someone?"),
        .init(number: 38, section: .communication, prompt: "How do you act when you are frustrated or disappointed?"),
        .init(number: 39, section: .communication, prompt: "How do you usually handle conflict?"),
        .init(number: 40, section: .communication, prompt: "What do you need from people who work closely with you?"),
        .init(number: 41, section: .workStyle, prompt: "How do you make decisions when information is incomplete?"),
        .init(number: 42, section: .workStyle, prompt: "How do you prioritize when many things matter at once?"),
        .init(number: 43, section: .workStyle, prompt: "What kind of work are you best at?"),
        .init(number: 44, section: .workStyle, prompt: "What kind of work do you avoid, delay, or dislike?"),
        .init(number: 45, section: .workStyle, prompt: "What standards do you expect from yourself?"),
        .init(number: 46, section: .workStyle, prompt: "What standards do you expect from your team or collaborators?"),
        .init(number: 47, section: .workStyle, prompt: "What does “doing a great job” mean to you?"),
        .init(number: 48, section: .workStyle, prompt: "What kind of mistakes are acceptable to you, and which are not?"),
        .init(number: 49, section: .values, prompt: "What do you ultimately want to build, become, or be known for?"),
        .init(number: 50, section: .values, prompt: "What beliefs, values, and non-negotiable principles guide your life and work?")
    ]
}

struct GeneratedFile: Identifiable, Hashable {
    let path: String
    let contents: String

    var id: String { path }
}

struct BuilderDraft: Codable {
    var buildMode: BuildMode = .newMainAgent
    var agentName: String = "Harbor"
    var nickname: String = "Harbor"
    var creature: String = "Lobster"
    var archetype: String = "Founder-side operator"
    var vibe: String = "Sharp, warm, direct, and high-agency."
    var emoji: String = "🦞"
    var agentDescription: String = "An OpenClaw-native agent that respects the official runtime, thinks clearly, and keeps growing with the founder."
    var userName: String = ""
    var userCallSign: String = "Founder"
    var communicationStyle: String = "Direct, supportive, skeptical, and evidence-first."
    var publicVoice: String = "Premium, capable, clear, and practical."
    var approvalStyle: String = "Take initiative on drafting, organization, and local file generation. Ask before risky external actions."
    var buildFluidityNote: String = "This agent is fluid. It can be retuned later as the founder, channels, and real jobs evolve."
    var primaryFocus: FocusPack = .founderCopilot
    var secondaryFocuses: Set<FocusPack> = [.operations, .research]
    var selectedJobs: Set<JobOption> = [.prioritizeWork, .draftStrategyMemos, .maintainWorkspaceMemory, .askDailyQuestions]
    var selectedChannels: Set<ChannelOption> = [.whatsapp, .blueBubbles, .telegram]
    var selectedBridges: Set<BridgePack> = [.browserSearch, .githubOps, .localScripts]
    var selectedAPIs: Set<ApiCatalogItem> = [.nationalWeatherService, .openMeteo, .nasa, .usgs]
    var summaryEnabledSections: Set<FounderQuestionSection> = [.personality, .communication, .workStyle, .values]
    var founderAnswers: [Int: String] = [:]
    var enableDailyQuestions: Bool = true
    var privateQuestionsOnly: Bool = true
    var remindIfUnanswered: Bool = true
    var allowQuestionFallback: Bool = true
    var includeQuestionBank: Bool = true
    var useFounderProfileInjection: Bool = true
    var bridgeNotes: String = ""
    var installNotes: String = ""

    /// IDs of ModelProvider entries the user has enabled.
    var enabledProviderIDs: Set<String> = ["anthropic"]

    /// IDs of ChannelSecret entries the user has enabled.
    var enabledChannelSecretIDs: Set<String> = []

    /// Map of ENV_VAR_NAME → key/value entered in the GUI. Values are
    /// held in-memory with the draft; we never write real keys to the
    /// workspace unless `includeKeysInGeneratedEnv` is true.
    var apiKeyValues: [String: String] = [:]

    /// When false (default), the generated `.env.example` only contains
    /// env-var names with blank values — safe to commit. When true, the
    /// user has explicitly opted into baking real keys into the file.
    var includeKeysInGeneratedEnv: Bool = false

    var agentSlug: String {
        slugify(agentName)
    }

    var orderedSecondaryFocuses: [FocusPack] {
        FocusPack.allCases.filter { secondaryFocuses.contains($0) && $0 != primaryFocus }
    }

    var orderedJobs: [JobOption] {
        JobOption.allCases.filter { selectedJobs.contains($0) }
    }

    var orderedChannels: [ChannelOption] {
        ChannelOption.allCases.filter { selectedChannels.contains($0) }
    }

    var orderedBridges: [BridgePack] {
        BridgePack.allCases.filter { selectedBridges.contains($0) }
    }

    var orderedAPIs: [ApiCatalogItem] {
        ApiCatalogItem.allCases.filter { selectedAPIs.contains($0) }
    }

    var answeredFounderQuestionsCount: Int {
        FounderQuestion.all.filter { founderAnswers[$0.number]?.nilIfBlank != nil }.count
    }
}
