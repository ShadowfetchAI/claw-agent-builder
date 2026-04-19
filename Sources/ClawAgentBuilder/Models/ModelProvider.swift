import Foundation

/// A friendly, GUI-first description of a model provider or bridge the
/// agent might talk to. This is what the "API Keys & Providers" wizard
/// iterates over — every field is there to make a pretty, explained
/// card the user can reason about without touching a terminal.
///
/// The point: turn "edit your .env and run `export ANTHROPIC_API_KEY=…`"
/// into "tick the provider you use, paste your key, and we'll generate
/// the right file for you."
struct ModelProvider: Identifiable, Hashable {
    let id: String
    let title: String
    let tagline: String          // One-sentence, friendly reason to pick this
    let symbolName: String       // SF Symbol for the card
    let envKey: String           // e.g. ANTHROPIC_API_KEY
    let signupURL: String        // Where to get a key
    let docsURL: String          // Provider docs
    let keyHint: String          // Placeholder for the secure field
    let access: AccessTier
    let notes: String            // Longer inline explanation

    enum AccessTier: String, Codable {
        case paid = "Paid"
        case freeTier = "Free tier available"
        case freeSignup = "Free with signup"
    }

    static func == (lhs: ModelProvider, rhs: ModelProvider) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum ModelProviderCatalog {
    /// Curated list. Order is rough "most-recommended first" for OpenClaw —
    /// Anthropic is the default because OpenClaw runs best on Claude.
    static let all: [ModelProvider] = [
        .init(
            id: "anthropic",
            title: "Anthropic (Claude)",
            tagline: "The default. OpenClaw runs best on Claude Sonnet / Opus.",
            symbolName: "sparkle",
            envKey: "ANTHROPIC_API_KEY",
            signupURL: "https://console.anthropic.com/settings/keys",
            docsURL: "https://docs.anthropic.com/",
            keyHint: "sk-ant-…",
            access: .paid,
            notes: "Recommended primary. Paste your key from console.anthropic.com — it starts with sk-ant-."
        ),
        .init(
            id: "openai",
            title: "OpenAI (GPT)",
            tagline: "Solid fallback. Good for quick experiments and cheap drafts.",
            symbolName: "circle.hexagongrid",
            envKey: "OPENAI_API_KEY",
            signupURL: "https://platform.openai.com/api-keys",
            docsURL: "https://platform.openai.com/docs",
            keyHint: "sk-…",
            access: .paid,
            notes: "Useful as a secondary model or for cheap background tasks."
        ),
        .init(
            id: "google",
            title: "Google (Gemini)",
            tagline: "Great free tier and strong at long-context research.",
            symbolName: "globe",
            envKey: "GOOGLE_API_KEY",
            signupURL: "https://aistudio.google.com/apikey",
            docsURL: "https://ai.google.dev/",
            keyHint: "AIza…",
            access: .freeTier,
            notes: "Create a key in Google AI Studio. Free tier is generous for personal use."
        ),
        .init(
            id: "groq",
            title: "Groq",
            tagline: "Very fast inference on Llama / Mixtral. Cheap and snappy.",
            symbolName: "bolt.fill",
            envKey: "GROQ_API_KEY",
            signupURL: "https://console.groq.com/keys",
            docsURL: "https://console.groq.com/docs",
            keyHint: "gsk_…",
            access: .freeTier,
            notes: "Ideal for low-latency helper tasks where Claude-class reasoning isn't required."
        ),
        .init(
            id: "openrouter",
            title: "OpenRouter",
            tagline: "One key, dozens of models. Useful for A/B testing.",
            symbolName: "arrow.triangle.branch",
            envKey: "OPENROUTER_API_KEY",
            signupURL: "https://openrouter.ai/keys",
            docsURL: "https://openrouter.ai/docs",
            keyHint: "sk-or-…",
            access: .freeSignup,
            notes: "Nice when you want to compare providers without juggling multiple keys."
        ),
        .init(
            id: "mistral",
            title: "Mistral",
            tagline: "Strong open-weights vendor with a clean API.",
            symbolName: "wind",
            envKey: "MISTRAL_API_KEY",
            signupURL: "https://console.mistral.ai/",
            docsURL: "https://docs.mistral.ai/",
            keyHint: "…",
            access: .paid,
            notes: "Good European option; pairs well with Claude for code review."
        )
    ]
}

/// Channel / bridge credentials the Tools + Bridges layer needs. Same
/// idea as ModelProvider but for things like Telegram bots and
/// BlueBubbles servers.
struct ChannelSecret: Identifiable, Hashable {
    let id: String
    let title: String
    let tagline: String
    let symbolName: String
    let envKey: String
    let signupURL: String
    let keyHint: String
    let notes: String

    static func == (lhs: ChannelSecret, rhs: ChannelSecret) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum ChannelSecretCatalog {
    static let all: [ChannelSecret] = [
        .init(
            id: "telegram",
            title: "Telegram bot token",
            tagline: "Message your agent on Telegram.",
            symbolName: "paperplane.fill",
            envKey: "TELEGRAM_BOT_TOKEN",
            signupURL: "https://t.me/BotFather",
            keyHint: "123456:ABC-DEF…",
            notes: "Open @BotFather in Telegram, run /newbot, and paste the token it hands you."
        ),
        .init(
            id: "discord",
            title: "Discord bot token",
            tagline: "Private DM routing for your agent.",
            symbolName: "gamecontroller",
            envKey: "DISCORD_BOT_TOKEN",
            signupURL: "https://discord.com/developers/applications",
            keyHint: "MTAx…",
            notes: "Create an Application, add a Bot, and paste the Bot Token here."
        ),
        .init(
            id: "bluebubbles",
            title: "BlueBubbles password",
            tagline: "Bridge iMessage through a BlueBubbles server you run.",
            symbolName: "bubble.left.and.bubble.right",
            envKey: "BLUEBUBBLES_PASSWORD",
            signupURL: "https://bluebubbles.app/",
            keyHint: "your server password",
            notes: "Requires a BlueBubbles server running on a Mac. This is the server password, not an API key."
        ),
        .init(
            id: "whatsapp",
            title: "WhatsApp bridge secret",
            tagline: "WhatsApp routing via a local bridge.",
            symbolName: "phone.bubble",
            envKey: "WHATSAPP_BRIDGE_SECRET",
            signupURL: "https://docs.openclaw.ai/",
            keyHint: "shared secret",
            notes: "Set whatever shared secret your WhatsApp bridge expects; OpenClaw reads it from this env var."
        )
    ]
}
