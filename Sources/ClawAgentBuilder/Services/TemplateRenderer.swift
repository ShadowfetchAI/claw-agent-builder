import Foundation

enum TemplateRenderer {
    static func generatedFiles(for draft: BuilderDraft, installStatus: OpenClawInstallStatus) -> [GeneratedFile] {
        var files: [GeneratedFile] = [
            // Canonical OpenClaw workspace files — these names and
            // positions match the real OpenClaw agent pack so the export
            // is drop-in compatible with ~/.openclaw/workspace.
            .init(path: "README.md", contents: readmeMarkdown(draft: draft)),
            .init(path: "AGENTS.md", contents: agentsMarkdown(draft: draft)),
            .init(path: "SOUL.md", contents: soulMarkdown(draft: draft)),
            .init(path: "IDENTITY.md", contents: identityMarkdown(draft: draft)),
            .init(path: "USER.md", contents: userMarkdown(draft: draft)),
            .init(path: "TOOLS.md", contents: toolsMarkdown(draft: draft)),
            .init(path: "MEMORY.md", contents: memoryMarkdown(draft: draft)),
            .init(path: "HEARTBEAT.md", contents: heartbeatMarkdown(draft: draft)),
            .init(path: "BOOT.md", contents: bootMarkdown(draft: draft)),
            .init(path: "BOOTSTRAP.md", contents: bootstrapMarkdown(draft: draft)),
            .init(path: "DREAMS.md", contents: dreamsMarkdown()),

            // Founder layer — builder-specific, not part of the stock
            // pack, but lives alongside the canonical files.
            .init(path: "FOUNDER.md", contents: founderMarkdown(draft: draft)),
            .init(path: "FOUNDER_PROFILE.md", contents: founderProfileMarkdown(draft: draft)),
            .init(path: "FOUNDER_QUESTIONNAIRE.md", contents: founderQuestionnaireMarkdown()),

            // Starter memory / state files — OpenClaw expects a daily
            // memory note and a heartbeat-state.json to already exist.
            .init(path: "memory/\(todayDateString()).md", contents: todayMemoryMarkdown(draft: draft)),
            .init(path: "memory/heartbeat-state.json", contents: heartbeatStateJSON()),

            // Build notes — exported so the user can audit what the
            // builder decided and why.
            .init(path: "BUILD_REPORT.md", contents: buildReportMarkdown(draft: draft, installStatus: installStatus)),
            .init(path: "INSTALL_GUIDE.md", contents: installGuideMarkdown(draft: draft)),

            // Data & skills
            .init(path: "data/API_CATALOG.md", contents: apiCatalogMarkdown(draft: draft)),
            .init(path: "data/API_SETUP.md", contents: apiSetupMarkdown(draft: draft)),
            .init(path: "skills/data-sources/SKILL.md", contents: dataSourcesSkillMarkdown(draft: draft)),
            .init(path: "skills/README.md", contents: skillsReadmeMarkdown()),

            // Optional folders — README stubs so the tree lands cleanly
            // when copied into ~/.openclaw/workspace.
            .init(path: "avatars/README.md", contents: avatarsReadmeMarkdown()),
            .init(path: "canvas/README.md", contents: canvasReadmeMarkdown()),

            // Config patch — a safe merge reference, not something the
            // user should blindly copy over their live config.
            .init(path: "openclaw.config.patch.json", contents: openclawConfigPatchJSON(draft: draft)),

            // Generated .env file from the API Keys & Providers wizard.
            // Named .env.example by default so it's safe to ship — the
            // user can `cp .env.example .env` (or ~/.openclaw/.env) to
            // activate it. When the user opts into baking real keys in,
            // this file carries their values instead of blanks.
            .init(path: ".env.example", contents: EnvFileGenerator.render(from: draft)),
        ]

        if draft.enableDailyQuestions {
            files.append(.init(path: "data/personality-plan.md", contents: personalityPlanMarkdown(draft: draft)))
            files.append(.init(path: "memory/personality-state.json", contents: personalityStateJSON(draft: draft)))
            files.append(.init(path: "skills/daily-personality-checkin/SKILL.md", contents: dailyQuestionsSkillMarkdown(draft: draft)))
        }

        return files
    }

    private static func agentsMarkdown(draft: BuilderDraft) -> String {
        """
        # AGENTS.md

        This workspace belongs to **\(draft.agentName)**.

        ## Session Startup

        Before doing anything else:

        1. Read `SOUL.md`
        2. Read `USER.md`
        3. Read `IDENTITY.md`
        4. Read `memory/YYYY-MM-DD.md` for today and yesterday when present
        5. In a main session, also read `MEMORY.md` when it exists
        6. If `BOOTSTRAP.md` exists, follow it once and then delete it

        ## Operating Rules

        - Primary mission: act as a \(draft.primaryFocus.title.lowercased()) built for \(draft.userCallSign.lowercased()) work.
        - Optimize for useful judgment, clean execution, and continuity over empty niceness.
        - Keep critical guidance in `AGENTS.md` and `TOOLS.md` because OpenClaw subagents only inherit those files.
        - Treat `TOOLS.md` as guidance about the environment. It does not control actual tool availability.
        - If you learn durable preferences, workflows, or patterns, promote them into `MEMORY.md` or this file instead of trusting chat history.
        - Do not store secrets in workspace files. Reference config or env names instead.
        - This agent is fluid. It may revise `AGENTS.md`, `SOUL.md`, and `MEMORY.md` over time when the human explicitly wants the agent sharpened.

        ## Current Focus

        - Primary focus: \(draft.primaryFocus.title)
        \(bullets(draft.orderedSecondaryFocuses.map(\.title), heading: "Secondary focuses"))
        \(bullets(draft.orderedJobs.map(\.title), heading: "Core jobs"))

        ## Founder Alignment

        - Use `FOUNDER_PROFILE.md` as the compact founder operating summary.
        - `FOUNDER.md` is private long-form context and should only be consulted when deeper alignment is actually needed.
        - Do not reveal intimate founder details unless the situation clearly requires them.
        \(draft.useFounderProfileInjection ? "- Founder profile injection is enabled. Keep advice aligned with the founder's direct preferences." : "- Founder profile injection is disabled by default. Only consult founder files when the user asks for deeper alignment.") 

        ## Channel Discipline

        \(bullets(draft.orderedChannels.map(\.title), heading: "Approved private channels"))
        - Do not ask daily getting-to-know-you questions in public channels or group surfaces unless the human explicitly changes that rule.

        ## Heartbeat

        - Keep `HEARTBEAT.md` tiny so OpenClaw does not waste tokens on maintenance runs.
        - Surface real issues, unanswered questions, or drift. Stay quiet when nothing meaningful changed.
        """
    }

    private static func soulMarkdown(draft: BuilderDraft) -> String {
        """
        # SOUL.md

        You are **\(draft.agentName)** \(draft.emoji)

        ## Core vibe

        \(draft.vibe)

        ## Personality

        - Creature / metaphor: \(draft.creature)
        - Archetype: \(draft.archetype)
        - Public voice: \(draft.publicVoice)
        - Working posture: \(draft.communicationStyle)

        ## Tone boundaries

        - Be direct without turning cold.
        - Be warm without becoming fake or submissive.
        - Be practical, specific, and OpenClaw-native.
        - Never sound like a generic “AI assistant” if stronger, clearer language is possible.
        - Call out uncertainty honestly instead of pretending.
        - If something conflicts with official OpenClaw behavior, prefer the verified OpenClaw path.
        """
    }

    private static func identityMarkdown(draft: BuilderDraft) -> String {
        """
        # IDENTITY.md

        - Name: \(draft.agentName)
        - Nickname: \(draft.nickname)
        - Emoji: \(draft.emoji)
        - Slug: \(draft.agentSlug)
        - Archetype: \(draft.archetype)
        - Creature: \(draft.creature)
        - Tagline: \(draft.agentDescription)
        """
    }

    private static func userMarkdown(draft: BuilderDraft) -> String {
        let founderName = draft.userName.nilIfBlank ?? "The founder"

        return """
        # USER.md

        You are helping **\(founderName)**.

        ## How to address the user

        - Preferred call sign: \(draft.userCallSign)
        - Default tone: \(draft.communicationStyle)
        - Approval style: \(draft.approvalStyle)

        ## Ground truth

        - The user wants a real OpenClaw agent, not generic AI slop.
        - Accuracy matters more than reassurance.
        - This system should complement OpenClaw's official install and onboarding, not fight it.
        - The agent can evolve later. Do not behave like today's wording is permanent law.

        ## Retuning

        \(draft.buildFluidityNote)
        """
    }

    private static func toolsMarkdown(draft: BuilderDraft) -> String {
        """
        # TOOLS.md

        This file describes the intended tool and bridge posture for this workspace. It does **not** control actual tool availability.

        ## Channels

        \(bullets(draft.orderedChannels.map { "\($0.title) — \($0.summary)" }, heading: "Approved channels"))

        ## Bridges

        \(bullets(draft.orderedBridges.map { "\($0.title) — \($0.summary)" }, heading: "Selected bridge packs"))

        ## Durable data sources

        \(bullets(draft.orderedAPIs.map { "\($0.title) — \($0.summary)" }, heading: "Selected APIs"))

        ## Notes

        \(draft.bridgeNotes.nilIfBlank ?? "No custom bridge notes captured yet.")
        """
    }

    private static func heartbeatMarkdown(draft: BuilderDraft) -> String {
        var lines = [
            "# HEARTBEAT.md",
            "",
            "- Stay tiny. This file exists only for small recurring checks.",
            "- Prefer approved private channels only."
        ]

        if draft.enableDailyQuestions {
            lines.append("- If there is no unanswered personality question, ask exactly one friendly getting-to-know-you question.")
            if draft.remindIfUnanswered {
                lines.append("- If the last question is still unanswered, send at most one gentle reminder.")
            } else {
                lines.append("- If the last question is still unanswered, wait quietly instead of pushing.")
            }
        } else {
            lines.append("- Daily getting-to-know-you questions are currently disabled.")
        }

        lines.append("- If nothing meaningful needs attention, stay silent.")
        return lines.joined(separator: "\n")
    }

    private static func founderMarkdown(draft: BuilderDraft) -> String {
        let sections = FounderQuestionSection.allCases.map { section in
            let sectionLines = FounderQuestion.all
                .filter { $0.section == section }
                .map { question in
                    let answer = draft.founderAnswers[question.number]?.nilIfBlank ?? "_Not answered yet._"
                    return "### \(question.number). \(question.prompt)\n\n\(answer)"
                }
                .joined(separator: "\n\n")

            return "## \(section.rawValue)\n\n\(sectionLines)"
        }
        .joined(separator: "\n\n")

        return """
        # FOUNDER.md

        Private long-form founder context for \(draft.agentName).

        Use this file for deep alignment when needed. Do not inject it wholesale into every run.

        \(sections)
        """
    }

    private static func founderProfileMarkdown(draft: BuilderDraft) -> String {
        let selectedSections = FounderQuestionSection.allCases.filter { draft.summaryEnabledSections.contains($0) }
        let sectionBlocks = selectedSections.map { section in
            let answered = FounderQuestion.all
                .filter { $0.section == section }
                .compactMap { question -> String? in
                    guard let answer = draft.founderAnswers[question.number]?.nilIfBlank else {
                        return nil
                    }
                    return "- **\(question.prompt)** \(answer)"
                }

            let body = answered.isEmpty ? "- No answers captured yet for this section." : answered.joined(separator: "\n")
            return "## \(section.rawValue)\n\n\(body)"
        }
        .joined(separator: "\n\n")

        return """
        # FOUNDER_PROFILE.md

        Compact founder operating summary for OpenClaw startup context.

        Keep this file tight enough to inject into the agent's worldview without dragging in every personal detail.

        \(sectionBlocks)
        """
    }

    private static func founderQuestionnaireMarkdown() -> String {
        let sections = FounderQuestionSection.allCases.map { section in
            let prompts = FounderQuestion.all
                .filter { $0.section == section }
                .map { "\($0.number). \($0.prompt)" }
                .joined(separator: "\n")

            return "## \(section.rawValue)\n\n\(prompts)"
        }
        .joined(separator: "\n\n")

        return """
        # Founder File Questionnaire

        Use this document to capture the core identity, background, working style, values, instincts, and long-term vision of a founder or principal.

        \(sections)
        """
    }

    private static func memoryMarkdown(draft: BuilderDraft) -> String {
        """
        # MEMORY.md

        Durable memory for \(draft.agentName).

        ## What belongs here

        - Founder preferences that keep repeating
        - Stable rules that should outlive one chat
        - Project realities that the agent should not relearn from scratch
        - Channel boundaries and bridge assumptions

        ## What does not belong here

        - Secrets
        - One-off chatter
        - Sensitive personal details that are not operationally useful

        ## Retune note

        \(draft.buildFluidityNote)
        """
    }

    private static func bootstrapMarkdown(draft: BuilderDraft) -> String {
        """
        # BOOTSTRAP.md

        You were forged by CLAW AGENT BUILDER.

        ## First run ritual

        1. Read `SOUL.md`, `USER.md`, `IDENTITY.md`, and `AGENTS.md`
        2. Confirm the primary focus is `\(draft.primaryFocus.title)`
        3. Confirm the approved channels and bridge posture in `TOOLS.md`
        4. Promote any durable truths into `MEMORY.md`
        5. Delete this file after the first successful grounding pass
        """
    }

    private static func buildReportMarkdown(draft: BuilderDraft, installStatus: OpenClawInstallStatus) -> String {
        """
        # BUILD_REPORT.md

        ## Builder summary

        - Agent name: \(draft.agentName)
        - Agent slug: \(draft.agentSlug)
        - Build mode: \(draft.buildMode.title)
        - Primary focus: \(draft.primaryFocus.title)
        - Founder questions answered: \(draft.answeredFounderQuestionsCount)/50

        ## Install detection

        - Status: \(installStatus.readiness.title)
        - CLI path: \(installStatus.cliPath ?? "Not found")
        - Config path: \(installStatus.configPath)
        - Workspace path: \(installStatus.workspacePath)

        ## Selected jobs

        \(bullets(draft.orderedJobs.map(\.title), heading: "Jobs"))

        ## Selected bridges

        \(bullets(draft.orderedBridges.map(\.title), heading: "Bridge packs"))

        ## Selected APIs

        \(bullets(draft.orderedAPIs.map(\.title), heading: "Durable APIs"))

        ## Manual follow-up

        - Finish the official OpenClaw install if it has not happened yet.
        - Use `openclaw onboard --install-daemon` for the official guided setup.
        - If you want a new isolated agent, register it with `openclaw agents add <name> --workspace ~/.openclaw/workspace-<name> --non-interactive`.
        - Review `openclaw.config.patch.json` and merge only the fields you actually want into your live `~/.openclaw/openclaw.json`.
        - Re-run CLAW AGENT BUILDER later to retune the same agent instead of treating this package as final forever.

        ## Builder notes

        \(draft.installNotes.nilIfBlank ?? "No extra builder notes captured yet.")
        """
    }

    private static func installGuideMarkdown(draft: BuilderDraft) -> String {
        """
        # INSTALL_GUIDE.md

        CLAW AGENT BUILDER complements the official OpenClaw install. It does not replace it.

        ## Official first-time setup

        1. Install OpenClaw

           `curl -fsSL https://openclaw.ai/install.sh | bash`

        2. Run official onboarding

           `openclaw onboard --install-daemon`

        3. Verify the Gateway

           `openclaw gateway status`

        4. Open the dashboard

           `openclaw dashboard`

        ## Why this order matters

        - OpenClaw handles the gateway, auth, model provider, channels, daemon, and default workspace.
        - CLAW AGENT BUILDER shapes the workspace files, founder layer, skills, data-source setup, and long-term personality tuning.

        ## Applying this package

        - Main agent path: merge these files into `~/.openclaw/workspace`
        - New isolated agent: create it with `openclaw agents add \(draft.agentSlug) --workspace ~/.openclaw/workspace-\(draft.agentSlug) --non-interactive`
        - Review and merge `openclaw.config.patch.json` by hand if you want the included heartbeat/startup defaults
        - Remote package: copy this folder to the gateway host and merge it there

        ## Ongoing retuning

        \(draft.buildFluidityNote)
        """
    }

    private static func apiCatalogMarkdown(draft: BuilderDraft) -> String {
        let entries = draft.orderedAPIs.map { api in
            """
            ## \(api.title)

            - Access: \(api.accessType.rawValue)
            - Why it belongs: \(api.summary)
            - Docs: \(api.docsURL)
            - Setup note: \(api.setupNote)
            """
        }
        .joined(separator: "\n\n")

        return """
        # API_CATALOG.md

        Durable, large-surface APIs selected for this workspace.

        \(entries)
        """
    }

    private static func apiSetupMarkdown(draft: BuilderDraft) -> String {
        let entries = draft.orderedAPIs.map { api in
            if let environmentKey = api.environmentKey {
                return """
                ## \(api.title)

                - Add the key outside the workspace.
                - Recommended env name: `\(environmentKey)`
                - Docs: \(api.docsURL)
                """
            } else {
                return """
                ## \(api.title)

                - No API key is required for the default use case.
                - Docs: \(api.docsURL)
                """
            }
        }
        .joined(separator: "\n\n")

        return """
        # API_SETUP.md

        Keep secrets out of workspace markdown. Use OpenClaw config, skill env wiring, or host environment variables.

        \(entries)
        """
    }

    private static func dataSourcesSkillMarkdown(draft: BuilderDraft) -> String {
        let requiresEnv = draft.orderedAPIs.compactMap(\.environmentKey)
        let metadata = requiresEnv.isEmpty
            ? #"{"openclaw":{"emoji":"🛰️"}}"#
            : #"{"openclaw":{"emoji":"🛰️","requires":{"env":["\#(requiresEnv.joined(separator: #"\",\""#))"]}}}"#

        return """
        ---
        name: data_sources
        description: Use the bundled API catalog and setup notes to reach durable public data sources.
        metadata: \(metadata)
        ---

        # Data Sources Skill

        Consult `data/API_CATALOG.md` to choose the right durable source first.

        When auth is required, read `data/API_SETUP.md` and use the configured environment variables instead of putting keys in prompts or workspace files.
        """
    }

    private static func personalityPlanMarkdown(draft: BuilderDraft) -> String {
        """
        # personality-plan.md

        ## Daily question rules

        - Ask one question per day.
        - Preferred private channels:
        \(bullets(draft.orderedChannels.map(\.title), heading: "Channel order"))
        - Do not ask in public or group contexts by default.
        - If the last question is unanswered, \(draft.remindIfUnanswered ? "send one gentle reminder and then wait." : "wait without pushing.")
        - Start with lighter trust-building questions before deeper founder material.
        - Promote only durable, useful answers into `FOUNDER_PROFILE.md` or `MEMORY.md`.
        """
    }

    private static func personalityStateJSON(draft: BuilderDraft) -> String {
        """
        {
          "enabled": \(draft.enableDailyQuestions ? "true" : "false"),
          "currentQuestion": 1,
          "lastAskedAt": null,
          "lastAnsweredAt": null,
          "awaitingAnswer": false,
          "privateOnly": \(draft.privateQuestionsOnly ? "true" : "false"),
          "allowFallback": \(draft.allowQuestionFallback ? "true" : "false"),
          "preferredChannels": [\(draft.orderedChannels.map { "\"\($0.rawValue)\"" }.joined(separator: ", "))],
          "questionBank": "data/personality-questions.txt"
        }
        """
    }

    private static func dailyQuestionsSkillMarkdown(draft: BuilderDraft) -> String {
        """
        ---
        name: daily_personality_checkin
        description: Ask one private getting-to-know-you question per day and store state in workspace memory.
        metadata: {"openclaw":{"emoji":"💬"}}
        ---

        # Daily Personality Check-In

        Read `data/personality-plan.md` and `memory/personality-state.json` before asking anything.

        Rules:

        - Ask at most one question per day.
        - Prefer approved private channels only.
        - If a question is already awaiting an answer, do not ask a new one.
        - Keep the tone warm and human, not clinical.
        - After a useful answer, consider whether a distilled version belongs in `FOUNDER_PROFILE.md` or `MEMORY.md`.
        """
    }

    private static func bullets(_ items: [String], heading: String) -> String {
        guard !items.isEmpty else {
            return "### \(heading)\n\n- None selected yet."
        }

        let lines = items.map { "- \($0)" }.joined(separator: "\n")
        return "### \(heading)\n\n\(lines)"
    }

    // MARK: - OpenClaw-native files added in the v2 export

    /// Top-level orientation for someone opening the workspace folder
    /// for the first time. Mirrors the structure of the official
    /// `openclaw-agent-pack` README so the files look familiar.
    private static func readmeMarkdown(draft: BuilderDraft) -> String {
        """
        # \(draft.agentName) — OpenClaw Agent Pack

        This workspace was shaped by **CLAW AGENT BUILDER** and is a full
        drop-in pack for OpenClaw.

        ## Where the files go

        ### Workspace
        Copy the workspace files into:

        `~/.openclaw/workspace`

        (Or, if this was installed directly by CLAW AGENT BUILDER, they
        are already there.)

        For isolated agents, OpenClaw's documented pattern is:

        `~/.openclaw/workspace-<agentId>`

        then register that workspace with:

        `openclaw agents add <agentId> --workspace ~/.openclaw/workspace-<agentId> --non-interactive`

        ### Config
        `openclaw.config.patch.json` is **not** a workspace file and should
        **not** replace your live config. Review it and merge only the
        fields you want into:

        `~/.openclaw/openclaw.json`

        ## What's in here

        ### Core workspace files
        - `AGENTS.md` — operating rules and guardrails
        - `SOUL.md` — voice, tone, stance, boundaries
        - `IDENTITY.md` — name, vibe, emoji, avatar
        - `USER.md` — who the agent helps
        - `TOOLS.md` — local environment notes
        - `MEMORY.md` — curated long-term memory
        - `HEARTBEAT.md` — tiny recurring checklist
        - `BOOT.md` — startup behavior on gateway restart
        - `BOOTSTRAP.md` — one-time first-run ritual (delete after)
        - `DREAMS.md` — review surface for memory consolidation

        ### Founder layer (builder-specific)
        - `FOUNDER.md` — private long-form founder context
        - `FOUNDER_PROFILE.md` — compact founder operating summary
        - `FOUNDER_QUESTIONNAIRE.md` — the 50-question source sheet

        ### Starter memory
        - `memory/\(todayDateString()).md` — today's daily note
        - `memory/heartbeat-state.json` — heartbeat state tracker

        ### Skills + data
        - `skills/data-sources/` — durable public data skill
        - `data/API_CATALOG.md` + `data/API_SETUP.md`
        \(draft.enableDailyQuestions ? "- `skills/daily-personality-checkin/` — one-question-a-day rapport skill\n" : "")
        ### Optional folders
        - `avatars/` — local avatar assets
        - `canvas/` — agent-driven UI files

        ## First run checklist

        1. Make sure the official OpenClaw CLI is installed and onboarded.
        2. Confirm `~/.openclaw/workspace` contains these files.
        3. Review `openclaw.config.patch.json` and merge any heartbeat/startup defaults you want into `~/.openclaw/openclaw.json`.
        4. Start a fresh session. The agent will follow `BOOTSTRAP.md` once.
        5. Delete `BOOTSTRAP.md` after the first successful grounding pass.

        ## Retuning later

        \(draft.buildFluidityNote)

        Re-open CLAW AGENT BUILDER → "Load from existing workspace" to pick up where this draft left off.
        """
    }

    /// Terse, OpenClaw-native BOOT.md. Kept short on purpose — long BOOT
    /// files waste tokens on every gateway restart.
    private static func bootMarkdown(draft: BuilderDraft) -> String {
        """
        # BOOT.md

        On gateway restart:

        1. Ensure today's `memory/YYYY-MM-DD.md` file exists
        2. Ensure `memory/heartbeat-state.json` exists
        3. Confirm core workspace files are present
        4. If the workspace is a git repo, note any uncommitted changes
        5. Do not send a startup message unless there is a real warning
        6. If you must message during BOOT, use the message tool and then reply `NO_REPLY`

        Agent: \(draft.agentName) \(draft.emoji)
        """
    }

    /// Review surface for memory consolidation. Matches the stock pack
    /// verbatim — there's nothing to customize here per-agent.
    private static func dreamsMarkdown() -> String {
        """
        # DREAMS.md

        Optional review surface for memory consolidation.

        Use this file for:
        - dreaming sweep summaries
        - candidate durable memories
        - review notes before promotion into `MEMORY.md`
        - historical backfill review output

        Keep it reviewable by a human.
        """
    }

    /// Empty-but-primed daily memory note. OpenClaw's runtime expects
    /// today's file to exist; shipping an empty-ish one avoids a cold
    /// start where the agent has to create the file first.
    private static func todayMemoryMarkdown(draft: BuilderDraft) -> String {
        """
        # \(todayDateString())

        First day of the \(draft.agentName) workspace.

        ## Open loops

        - Confirm identity and user call-sign with \(draft.userCallSign.nilIfBlank ?? "the founder")
        - Verify the approved channels match what's set in `TOOLS.md`

        ## Notes

        _(Agent: append observations, follow-ups, and raw context here during the day.)_
        """
    }

    /// Initial heartbeat-state.json the agent can update each pulse.
    /// Keys match OpenClaw's expected shape.
    private static func heartbeatStateJSON() -> String {
        """
        {
          "lastCheckAt": null,
          "lastActionAt": null,
          "consecutiveQuietPulses": 0,
          "openLoops": []
        }
        """
    }

    private static func skillsReadmeMarkdown() -> String {
        """
        # Skills

        Workspace-local skills live here. Each skill has its own folder with a
        `SKILL.md` and optional resources.

        - `SKILL.md` is the authoritative guide for when and how to use a skill.
        - Keep secrets and credentials out of skill files. Use env vars.
        - Add new skills by creating a sibling folder and a `SKILL.md` inside.
        """
    }

    private static func avatarsReadmeMarkdown() -> String {
        """
        # Avatars

        Local avatar assets for this agent.

        The default avatar shipped by CLAW AGENT BUILDER is `agent.png`.
        Reference it in `IDENTITY.md` using a workspace-relative path:

        `Avatar: avatars/agent.png`

        Swap in your own image by replacing `agent.png` — keep the filename
        so `IDENTITY.md` stays valid.
        """
    }

    private static func canvasReadmeMarkdown() -> String {
        """
        # Canvas

        Agent-driven UI files and lightweight surfaces.

        Drop HTML, markdown dashboards, or small static assets here when the
        agent needs a place to render or stage visual artifacts. This folder
        is optional — OpenClaw doesn't require anything specific in here.
        """
    }

    /// `openclaw.config.patch.json` — safe merge snippet for the live
    /// config. We intentionally do not tell the user to overwrite the
    /// whole config file because onboarding may already own real
    /// provider, routing, or agent settings.
    private static func openclawConfigPatchJSON(draft: BuilderDraft) -> String {
        let timezone = TimeZone.current.identifier

        return """
        {
          "agents": {
            "defaults": {
              "contextInjection": "continuation-skip",
              "userTimezone": "\(timezone)",
              "startupContext": {
                "enabled": true,
                "applyOn": [
                  "new",
                  "reset"
                ],
                "dailyMemoryDays": 2,
                "maxFileBytes": 16384,
                "maxFileChars": 1200,
                "maxTotalChars": 2800
              },
              "heartbeat": {
                "every": "30m",
                "includeReasoning": false,
                "includeSystemPromptSection": true,
                "lightContext": true,
                "isolatedSession": true,
                "target": "none",
                "directPolicy": "allow",
                "ackMaxChars": 300,
                "timeoutSeconds": 45
              }
            }
          }
        }
        """
    }

    /// Today's local-date string in ISO format (YYYY-MM-DD). Used for
    /// naming the starter memory note and in README examples.
    static func todayDateString(now: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: now)
    }
}
