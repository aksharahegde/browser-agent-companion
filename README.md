# CUA Companion

Mac menu-bar companion that bridges local desktop capabilities (screenshot, clipboard, files, hotkeys) to the Cloudflare Stateful Browser Agent.

## Requirements

- macOS 12+
- Flutter 3.5+ (stable channel)
- Cloudflare `stateful-browser-agent` backend deployed and reachable

## Setup

```bash
flutter pub get
dart run build_runner build
```

## Run

```bash
flutter run -d macos
```

The app runs as a menu-bar agent (no Dock icon). Use the tray icon to open the overlay, run workflows, or quit.

## Quit

- Menu bar → **Quit CUA Companion**
- Overlay → `⋯` menu → **Quit**
- Settings → **Quit App**
- **Cmd+Q**

## Configuration

Open **Settings** from the tray menu:

- **Agent host URL** — your deployed Worker URL
- **Session ID** — stable per-machine agent session
- **Auth token** — optional, passed as WebSocket query param

## Permissions

Grant **Screen Recording** in System Settings → Privacy & Security when using screenshot workflows.

## Build release

```bash
flutter build macos --release
open build/macos/Build/Products/Release/cua_companion.app
```

## Architecture

See [docs/plan.md](docs/plan.md) for the full implementation plan.
