import Foundation

/// Static reference library of practical OpenClaw knowledge baked into
/// the app so beginners don't have to jump to the docs for common
/// tasks. All strings in this file come from the official OpenClaw
/// documentation (docs.openclaw.ai) — kept grouped by purpose so the
/// UI can render cheatsheets, troubleshooting, and glossary content
/// without hardcoding copy in view code.
enum OpenClawKnowledge {

    // MARK: - CLI cheatsheet

    struct CLIGroup: Identifiable, Hashable {
        let id: String
        let title: String
        let blurb: String
        let commands: [CLICommand]
    }

    struct CLICommand: Identifiable, Hashable {
        var id: String { command }
        let command: String
        let purpose: String
    }

    static let cliGroups: [CLIGroup] = [
        CLIGroup(
            id: "core",
            title: "Core & status",
            blurb: "Day-to-day commands for seeing what your agent is doing.",
            commands: [
                CLICommand(command: "openclaw status", purpose: "One-line health snapshot of gateway + daemon."),
                CLICommand(command: "openclaw doctor", purpose: "Full diagnostic — checks Node, Gateway, daemon, config."),
                CLICommand(command: "openclaw health", purpose: "Readable health check with remediation hints."),
                CLICommand(command: "openclaw dashboard", purpose: "Open the local Control UI in your browser."),
                CLICommand(command: "openclaw tui", purpose: "Terminal UI view of the agent.")
            ]
        ),
        CLIGroup(
            id: "gateway",
            title: "Gateway",
            blurb: "The local server (default port 18789) every channel and CLI talks to.",
            commands: [
                CLICommand(command: "openclaw gateway status", purpose: "Confirms the gateway is up on port 18789."),
                CLICommand(command: "openclaw gateway restart", purpose: "Cycles the gateway service — first fix for most 'not responding' issues."),
                CLICommand(command: "openclaw gateway-lock", purpose: "Manage gateway access controls.")
            ]
        ),
        CLIGroup(
            id: "daemon",
            title: "Daemon",
            blurb: "The background process that keeps your agent alive after Terminal closes.",
            commands: [
                CLICommand(command: "openclaw daemon status", purpose: "Is the background daemon running?"),
                CLICommand(command: "openclaw daemon restart", purpose: "Cycle the daemon without rebooting."),
                CLICommand(command: "openclaw logs", purpose: "Tail recent daemon + gateway logs.")
            ]
        ),
        CLIGroup(
            id: "agents",
            title: "Agents & workspaces",
            blurb: "Manage multiple agent workspaces in one install.",
            commands: [
                CLICommand(command: "openclaw agents", purpose: "List every registered agent workspace."),
                CLICommand(command: "openclaw agents add <slug> --workspace <path>", purpose: "Register a new isolated agent at a custom workspace path."),
                CLICommand(command: "openclaw agent <slug> status", purpose: "Status of one specific agent.")
            ]
        ),
        CLIGroup(
            id: "channels",
            title: "Channels",
            blurb: "Places your agent can speak — Discord, Slack, Telegram, iMessage, and more.",
            commands: [
                CLICommand(command: "openclaw channels", purpose: "List configured channels and their status."),
                CLICommand(command: "openclaw channels add", purpose: "Interactive add-a-channel flow."),
                CLICommand(command: "openclaw pairing", purpose: "Pair a mobile device or companion."),
                CLICommand(command: "openclaw qr", purpose: "Show a QR code for quick device pairing.")
            ]
        ),
        CLIGroup(
            id: "skills",
            title: "Skills & tools",
            blurb: "Reusable ability packs: web search, sandbox, image gen, etc.",
            commands: [
                CLICommand(command: "openclaw skills", purpose: "List installed skills."),
                CLICommand(command: "openclaw skills add <name>", purpose: "Install a built-in skill."),
                CLICommand(command: "openclaw skills remove <name>", purpose: "Uninstall a skill."),
                CLICommand(command: "openclaw mcp", purpose: "Manage Model Context Protocol servers."),
                CLICommand(command: "openclaw plugins", purpose: "Manage third-party plugins.")
            ]
        ),
        CLIGroup(
            id: "memory",
            title: "Memory & sessions",
            blurb: "What the agent remembers and when.",
            commands: [
                CLICommand(command: "openclaw memory", purpose: "Inspect or prune the agent's memory store."),
                CLICommand(command: "openclaw sessions", purpose: "List recent conversation sessions.")
            ]
        ),
        CLIGroup(
            id: "automation",
            title: "Automation",
            blurb: "Run things on a schedule or react to events.",
            commands: [
                CLICommand(command: "openclaw cron", purpose: "Manage scheduled tasks."),
                CLICommand(command: "openclaw hooks", purpose: "Configure webhooks / event hooks."),
                CLICommand(command: "openclaw flows", purpose: "Task workflow management."),
                CLICommand(command: "openclaw webhooks", purpose: "Inbound webhook endpoints.")
            ]
        ),
        CLIGroup(
            id: "maintenance",
            title: "Maintenance & recovery",
            blurb: "Back up, update, reset, or start over.",
            commands: [
                CLICommand(command: "openclaw update", purpose: "Update the CLI to the latest release."),
                CLICommand(command: "openclaw backup", purpose: "Snapshot your config + workspace."),
                CLICommand(command: "openclaw reset", purpose: "Reset config, credentials, and sessions (keeps workspace)."),
                CLICommand(command: "openclaw reset --reset-scope full", purpose: "Full reset including workspace. Destructive — back up first."),
                CLICommand(command: "openclaw uninstall", purpose: "Remove OpenClaw from this machine.")
            ]
        ),
        CLIGroup(
            id: "advanced",
            title: "Advanced",
            blurb: "Power-user surfaces — useful once you're comfortable.",
            commands: [
                CLICommand(command: "openclaw secrets", purpose: "Credential management (env-var refs, keychain)."),
                CLICommand(command: "openclaw approvals", purpose: "Review / approve pending actions."),
                CLICommand(command: "openclaw sandbox", purpose: "Manage the code execution sandbox."),
                CLICommand(command: "openclaw browser", purpose: "Headless browser automation surface."),
                CLICommand(command: "openclaw infer", purpose: "Direct model inference utilities."),
                CLICommand(command: "openclaw voicecall", purpose: "Voice call operations."),
                CLICommand(command: "openclaw directory", purpose: "Device + directory management."),
                CLICommand(command: "openclaw nodes", purpose: "Manage connected nodes."),
                CLICommand(command: "openclaw completion", purpose: "Install shell tab-completion.")
            ]
        )
    ]

    // MARK: - Environment variables

    struct EnvVar: Identifiable, Hashable {
        var id: String { name }
        let name: String
        let purpose: String
    }

    static let environmentVariables: [EnvVar] = [
        EnvVar(name: "OPENCLAW_HOME", purpose: "Override the home directory OpenClaw resolves state + config under. Defaults to ~/.openclaw."),
        EnvVar(name: "OPENCLAW_STATE_DIR", purpose: "Override just the state directory (logs, sessions, memory)."),
        EnvVar(name: "OPENCLAW_CONFIG_PATH", purpose: "Override the config file path. Defaults to $OPENCLAW_HOME/openclaw.json.")
    ]

    // MARK: - Workspace file reference

    struct WorkspaceFile: Identifiable, Hashable {
        var id: String { path }
        let path: String
        let purpose: String
    }

    static let workspaceFiles: [WorkspaceFile] = [
        WorkspaceFile(path: "AGENTS.md", purpose: "Root agent definition — who this agent is, how it behaves, what it will and won't do."),
        WorkspaceFile(path: "AGENTS.default.md", purpose: "Stock OpenClaw agent definition kept for reference. Your AGENTS.md overrides it."),
        WorkspaceFile(path: "SOUL.md", purpose: "Personality and tone — the 'voice' the model will take on."),
        WorkspaceFile(path: "IDENTITY.md", purpose: "Name, nickname, emoji, archetype. How the agent introduces itself."),
        WorkspaceFile(path: "USER.md", purpose: "Facts about you the agent should always remember — call sign, preferences, communication style."),
        WorkspaceFile(path: "TOOLS.md", purpose: "Human-readable description of the tools and skills this agent should reach for."),
        WorkspaceFile(path: "MEMORY.md", purpose: "Long-lived memory notes. Daily memories live in memory/<date>.md."),
        WorkspaceFile(path: "HEARTBEAT.md", purpose: "Periodic tasks — what the agent should do on a schedule without being asked."),
        WorkspaceFile(path: "BOOT.md", purpose: "Boot sequence — what the agent should load and check at startup."),
        WorkspaceFile(path: "BOOTSTRAP.md", purpose: "One-time setup notes for the first boot."),
        WorkspaceFile(path: "DREAMS.md", purpose: "Stretch goals and aspirational behaviors, separate from hard rules."),
        WorkspaceFile(path: "FOUNDER.md", purpose: "Founder file — your story and mission, so the agent has context for judgment calls."),
        WorkspaceFile(path: ".env.example", purpose: "Environment variables the agent needs. Safe-by-default; keys blank unless you opted in."),
        WorkspaceFile(path: "memory/<date>.md", purpose: "Daily memory file. Rotated automatically."),
        WorkspaceFile(path: "skills/", purpose: "Folder of installed skill manifests."),
        WorkspaceFile(path: "heartbeat-state.json", purpose: "State file the daemon updates as heartbeat tasks run.")
    ]

    // MARK: - Troubleshooting first-aid

    struct Troubleshoot: Identifiable, Hashable {
        var id: String { symptom }
        let symptom: String
        let tryThis: String
        let command: String?
    }

    static let troubleshooting: [Troubleshoot] = [
        Troubleshoot(
            symptom: "Gateway isn't responding on port 18789.",
            tryThis: "Restart the gateway. This fixes most transient issues.",
            command: "openclaw gateway restart"
        ),
        Troubleshoot(
            symptom: "Agent feels frozen or commands time out.",
            tryThis: "Cycle the daemon and watch the logs for a minute.",
            command: "openclaw daemon restart && openclaw logs"
        ),
        Troubleshoot(
            symptom: "Not sure what's wrong — where do I start?",
            tryThis: "Run the doctor. It's the official 'what's broken' checklist.",
            command: "openclaw doctor"
        ),
        Troubleshoot(
            symptom: "Config or credentials seem off.",
            tryThis: "Reset config/credentials/sessions only. Your workspace is kept.",
            command: "openclaw reset"
        ),
        Troubleshoot(
            symptom: "Everything is tangled and I want a clean slate.",
            tryThis: "Back up first, then full reset. This also wipes the workspace.",
            command: "openclaw backup && openclaw reset --reset-scope full"
        ),
        Troubleshoot(
            symptom: "Node errors during install on Apple Silicon.",
            tryThis: "Make sure Node is on PATH for login shells — /bin/bash -lc should resolve `node`.",
            command: "/bin/bash -lc 'node -v'"
        ),
        Troubleshoot(
            symptom: "CLI isn't found after install.",
            tryThis: "Open a new Terminal window so the installer's PATH edits take effect.",
            command: nil
        ),
        Troubleshoot(
            symptom: "Port 18789 is already in use.",
            tryThis: "Find the process on the port and decide whether to stop it.",
            command: "lsof -i :18789"
        )
    ]

    // MARK: - Channels catalog (official supported set)

    struct ChannelInfo: Identifiable, Hashable {
        var id: String { name }
        let name: String
        let category: String
    }

    static let channels: [ChannelInfo] = [
        ChannelInfo(name: "Discord", category: "Enterprise / team"),
        ChannelInfo(name: "Slack", category: "Enterprise / team"),
        ChannelInfo(name: "Microsoft Teams", category: "Enterprise / team"),
        ChannelInfo(name: "Google Chat", category: "Enterprise / team"),
        ChannelInfo(name: "Mattermost", category: "Enterprise / team"),
        ChannelInfo(name: "Matrix", category: "Enterprise / team"),
        ChannelInfo(name: "Nextcloud Talk", category: "Enterprise / team"),
        ChannelInfo(name: "Telegram", category: "Consumer"),
        ChannelInfo(name: "WhatsApp", category: "Consumer"),
        ChannelInfo(name: "Signal", category: "Consumer"),
        ChannelInfo(name: "iMessage (BlueBubbles)", category: "Consumer"),
        ChannelInfo(name: "WeChat", category: "Consumer"),
        ChannelInfo(name: "LINE", category: "Consumer"),
        ChannelInfo(name: "Zalo", category: "Consumer"),
        ChannelInfo(name: "QQ Bot", category: "Consumer"),
        ChannelInfo(name: "IRC", category: "Specialized"),
        ChannelInfo(name: "Nostr", category: "Specialized"),
        ChannelInfo(name: "Twitch", category: "Specialized"),
        ChannelInfo(name: "Synology Chat", category: "Specialized"),
        ChannelInfo(name: "Feishu", category: "Specialized"),
        ChannelInfo(name: "Tlon", category: "Specialized")
    ]

    // MARK: - Built-in skill categories

    struct SkillCategory: Identifiable, Hashable {
        var id: String { name }
        let name: String
        let examples: String
    }

    static let skillCategories: [SkillCategory] = [
        SkillCategory(name: "Web search", examples: "Brave, DuckDuckGo, Exa, Tavily, Perplexity, Firecrawl, Gemini"),
        SkillCategory(name: "Browser automation", examples: "Headless fetch, page scraping, click-through flows"),
        SkillCategory(name: "Sandbox execution", examples: "Run code safely in an isolated sandbox"),
        SkillCategory(name: "Image + video generation", examples: "Model-backed image/video producers"),
        SkillCategory(name: "Audio + text-to-speech", examples: "Voice output and audio processing"),
        SkillCategory(name: "PDF handling", examples: "Parse, extract, summarize PDFs"),
        SkillCategory(name: "Patch / diff", examples: "Apply unified diffs to files"),
        SkillCategory(name: "Sub-agent delegation", examples: "Spawn focused sub-agents for tasks"),
        SkillCategory(name: "Elevated execution", examples: "Run approved privileged commands"),
        SkillCategory(name: "LLM task delegation", examples: "Hand off a subtask to a different model"),
        SkillCategory(name: "Plugin framework", examples: "Third-party MCP servers and plugins")
    ]

    // MARK: - Model providers (official supported set, short form)

    static let supportedModelProviders: [String] = [
        "Anthropic (default)", "OpenAI", "Google Gemini", "Mistral", "Groq",
        "DeepSeek", "xAI", "Together AI", "Fireworks", "LiteLLM",
        "Ollama (local)", "vLLM (local)", "Amazon Bedrock", "Azure OpenAI",
        "GitHub Copilot", "Qwen", "GLM", "Moonshot", "Qianfan", "OpenRouter"
    ]

    // MARK: - Wizard flags

    struct WizardFlag: Identifiable, Hashable {
        var id: String { flag }
        let flag: String
        let purpose: String
    }

    static let wizardFlags: [WizardFlag] = [
        WizardFlag(flag: "--install-daemon", purpose: "Install the background daemon during onboarding."),
        WizardFlag(flag: "--non-interactive", purpose: "Script-friendly mode — no prompts."),
        WizardFlag(flag: "--secret-input-mode ref", purpose: "Store env-var references instead of plaintext keys."),
        WizardFlag(flag: "--gateway-token-ref-env <ENV_VAR>", purpose: "Non-interactive gateway token supplied via an env var name."),
        WizardFlag(flag: "--reset", purpose: "Reset config, credentials, and sessions."),
        WizardFlag(flag: "--reset-scope full", purpose: "Extend a reset to include the workspace. Destructive."),
        WizardFlag(flag: "--json", purpose: "Machine-readable JSON output (distinct from --non-interactive).")
    ]
}
