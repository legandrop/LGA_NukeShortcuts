# LGA Nuke Shortcuts

Two keyboard shortcuts for Nuke and NukeX that the application doesn't have out of the box. The app
lives in the Windows tray (or the macOS menu bar) and only listens while Nuke is in front. Every
other app keeps these key combinations.

| Shortcut | What it does |
| --- | --- |
| **Ctrl+Shift+D** | Sets a key on the knob under the pointer (right click → *Set key*). |
| **Ctrl+Alt+Shift+D** | Selects every key in the Dope Sheet and frames them, then puts the pointer back where it was. |

On macOS, Ctrl becomes **⌘**, the same way it does in Nuke. You can change both shortcuts from the
Settings window.

## Calibrating the Dope Sheet

*Frame Dope Sheet* clicks an empty spot of your Dope Sheet before selecting and framing. Tell the
app where that spot is once:

1. Open Nuke with the Dope Sheet visible.
2. Open **Calibrate Dope Sheet...** from the tray menu or from Settings, and click **Start**.
3. Click an empty spot inside the Dope Sheet. Esc cancels.

The spot is saved relative to the Nuke window, so it keeps working if you move the window, resize
it or open Nuke on another monitor. Calibrate again if you change your panel layout.

## Install

- **Windows:** run `LGA_NukeShortcuts_Setup_v<version>.exe` from the
  [releases](https://github.com/legandrop/LGA_NukeShortcuts/releases). No admin rights needed. The
  app starts with Windows by default; you can turn that off in Settings. It checks for updates at
  startup (also optional).
- **macOS:** coming soon. The app will ask for **Accessibility** access, which macOS requires
  before an app can send clicks and keys to another app.

If you used the older AutoHotkey version, close it and remove its shortcut from the Windows
Startup folder before you start this one. Both can't hold the same shortcuts at once.

## Build

Qt 6.5 with MinGW (Windows) or Homebrew Qt 6 (macOS), CMake and Ninja.

- Windows: `compilar.bat` (Debug in `build\`), `compilar.bat --release`, `deploy.bat` (portable
  folder in `deploy\`) and `instalador.bat` (Inno Setup 6 installer).
- macOS: `./compilar.sh` (Debug in `build/`), `./compilar.sh --release`.
- `LGA_NukeShortcuts --self-test` checks the logic that doesn't need a screen.

## Older version

The original AutoHotkey version (v1.x, Windows only) is in [`Legacy_AHK/`](Legacy_AHK/).

Lega Pugliese · [github.com/legandrop](https://github.com/legandrop)
