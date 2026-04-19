# CLAW Agent Builder

A friendly macOS app that guides you through building an [OpenClaw](https://docs.openclaw.ai) agent — one clear step at a time. Pick a starting preset, fine-tune the agent's identity, focus, tools, daily routine, and API keys, then export a complete workspace pack you can drop straight into `~/.openclaw/workspace`.

Built for people who want an easy way into AI without giving up control.

---

## What it does

CLAW Agent Builder is a SwiftUI wizard that produces a real OpenClaw workspace — the same set of files OpenClaw reads at runtime. Instead of hand-editing markdown and JSON, you answer plain-English questions and the app generates:

- **Real OpenClaw workspace files**: `AGENTS.md`, `SOUL.md`, `IDENTITY.md`, `USER.md`, `TOOLS.md`, `MEMORY.md`, `HEARTBEAT.md`, `BOOT.md`, `BOOTSTRAP.md`, `DREAMS.md`, `README.md`
- **Founder files**: `FOUNDER.md`, `FOUNDER_PROFILE.md`, and the full questionnaire
- **Scaffolding**: `memory/<today>.md`, `memory/heartbeat-state.json`
- **Config patch**: `openclaw.config.patch.json` you can review and merge into your live `~/.openclaw/openclaw.json`
- **Asset stubs**: `skills/`, `avatars/`, `canvas/` with starter READMEs
- **Reloadable draft**: hidden `.claw-builder/builder-profile.json` so you can reopen and retune the same agent later

The app also bundles the official OpenClaw CLI cheatsheet, a troubleshooting first-aid kit, and live status checks for Node, Homebrew, and the OpenClaw install itself — so you can spot-check prerequisites without leaving the builder.

## Screens

The wizard moves through ten clear sections:

1. **Welcome** — pick a preset, choose your starting lane ("I already have OpenClaw" vs. full install)
2. **Install OpenClaw** — guided installer with Terminal automation for first-timers
3. **Identity** — name, slug, voice, values
4. **Focus** — what the agent actually does all day
5. **Founder file** — the "who you are" profile the agent wakes up knowing
6. **Tools & Bridges** — which capabilities and channels to enable
7. **Daily Questions** — the heartbeat prompts the agent asks itself
8. **Data Sources** — vaults, notes, inbox feeds
9. **API Keys** — provider credentials with live connectivity testing
10. **Preview & Export** — diff every generated file, then install

## Requirements

- macOS 14.0 (Sonoma) or later
- Swift 6.3 toolchain (ships with Xcode 16.4+)
- For the full-install edition: a login shell with `node` ≥ 18 on `PATH` (the app resolves nvm/fnm/asdf/Homebrew-on-Apple-Silicon via `/bin/bash -lc`)

## Build & run

```sh
# Build + run the full Developer ID edition
./script/build_and_run.sh
```

That wraps the Swift Package Manager executable in a proper `.app`, writes the Info.plist, and launches.

### Two editions from one codebase

| | Developer ID edition | App Store edition |
|---|---|---|
| Install wizard | ✅ Full — runs `install.sh`, drives Terminal | ❌ Hidden (sandbox restriction) |
| Live workspace writes | ✅ Writes to `~/.openclaw/workspace` | ❌ User-picked folder only |
| "Run in Terminal" buttons | ✅ Everywhere | ❌ Replaced with Copy |
| Node / Brew / CLI detection | ✅ Live via login shell | ❌ Fixed "unknown" |
| Provider key testing | ✅ | ✅ |
| Agent generation + preview | ✅ | ✅ |

Build the App Store edition with:

```sh
swift build -c release -Xswiftc -DAPPSTORE_BUILD
# or, for a signed + packaged build ready for Transporter:
APP_SIGN_IDENTITY="3rd Party Mac Developer Application: Your Name (TEAMID)" \
INSTALLER_SIGN_IDENTITY="3rd Party Mac Developer Installer: Your Name (TEAMID)" \
./script/build_appstore.sh pkg
```

The `-DAPPSTORE_BUILD` flag strips all `Process`, `NSAppleScript`, and shell-out code out of the binary at compile time and hides the install wizard from the UI, so the sandboxed build contains nothing Apple can reject for out-of-sandbox execution.

## Project layout

```
Sources/ClawAgentBuilder/
├── Models/              # BuilderDraft, presets, install targets
├── Services/            # BuilderStore, TemplateRenderer, WorkspaceInstaller,
│                         # OpenClawInstaller, ProviderKeyTester, DraftService
├── Support/             # BuildFlavor flag, artwork, string utilities
└── Views/
    ├── Sections/        # One view per wizard section
    └── Shared/          # Sidebar, header bar, footer, reference cards

script/
├── build_and_run.sh              # Developer ID build
├── build_appstore.sh             # Sandboxed App Store build + sign + pkg
└── ClawAgentBuilder.entitlements # Sandbox entitlements for the App Store build
```

## How the generated files get into OpenClaw

The **Preview & Export** section lets you pick the install target:

- **Desktop preview** — timestamped folder under `~/Desktop/`, safe to inspect
- **Live main workspace** — writes directly to `~/.openclaw/workspace` (existing files backed up first)
- **Isolated workspace** — writes to `~/.openclaw/workspace-<slug>`; run `openclaw agents add <slug> --workspace ~/.openclaw/workspace-<slug> --non-interactive` to register it
- **Custom folder** — any location you pick via the file picker

The App Store edition is restricted to "Custom folder" because the sandbox can't reach `~/.openclaw/` without a user-granted bookmark — you pick a staging folder, then `cp -R` into your workspace yourself.

## Drafts

Every export also drops a `.claw-builder/builder-profile.json` into the package. Load it back in from the **Drafts** card on the Preview page to pick up exactly where you left off and retune without starting over.

## License

Copyright © 2026 Shadowfetch. All rights reserved.

## Acknowledgments

Built on top of the official [OpenClaw](https://docs.openclaw.ai) CLI and file conventions. This app doesn't replace OpenClaw — it helps you configure it.
