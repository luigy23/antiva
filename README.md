# Antiva

A lightweight macOS menu bar task manager built with SwiftUI.

## Features

- **Menu bar only** — lives in your menu bar, no Dock icon
- **Quick task entry** — add tasks with Enter or the + button
- **Checkboxes** — mark tasks as completed
- **Floating desktop widget** — toggle a draggable widget that stays on top of all windows
- **Persistent storage** — tasks survive app restarts via UserDefaults
- **Light mode UI** — clean, minimal interface with forced light theme

## Requirements

- macOS 14.0 (Sonoma) or later

## Installation

1. Download `Antiva.zip` from [Releases](../../releases)
2. Extract and move `Antiva.app` to `/Applications/`
3. First launch: right-click → Open (to bypass Gatekeeper)

## Building from source

```bash
git clone git@github.com:luigyleonardo/antiva.git
cd antiva
xcodebuild -project Antiva.xcodeproj -target Antiva -configuration Release CONFIGURATION_BUILD_DIR="$(pwd)/build" CODE_SIGN_IDENTITY="-"
```

The built app will be at `build/Antiva.app`.

## Project Structure

```
antiva/
├── Antiva/
│   ├── AntivaApp.swift        # App entry point (MenuBarExtra)
│   ├── ContentView.swift      # Menu bar popover UI
│   ├── TaskModel.swift        # Task data model + persistence
│   ├── DesktopWidget.swift    # Floating desktop widget (NSPanel)
│   ├── Info.plist
│   └── Assets.xcassets/
├── Antiva.xcodeproj/
└── README.md
```

## License

MIT
