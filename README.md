# MBPasCODE

My MacBook Pro setup as code. Run the bootstrap script on a fresh Mac to get an identical environment.

## Quick Start

```bash
git clone https://github.com/bryanshamilton/MBPasCODE.git
cd MBPasCODE
chmod +x setup.sh
./setup.sh
```

### Post-Setup (manual steps)

1. **SSH key** — run `scripts/setup_ssh.sh` to generate a key and add it to GitHub
2. **BetterTouchTool** — import `config/btt/exported_triggers.bttpreset` via Presets → Import
3. **Log out/in** for wallpaper and trackpad changes to fully apply

## What's Included

| Category | Tools |
|----------|-------|
| **Terminal** | Ghostty (Catppuccin Mocha), Fish shell, Starship prompt |
| **Window Management** | Aerospace (tiling), Borders (active window highlight), AutoRaise (focus follows mouse) |
| **Gestures** | BetterTouchTool — 3/4-finger swipe for Aerospace workspace switching |
| **Menu Bar** | Ice (hide/show sections, layout) |
| **CLI Tools** | atuin, bat, eza, fd, fzf, ripgrep, zoxide, direnv |
| **Dev** | git, gh, nvm, awscli, Docker Desktop, VS Code |
| **Apps** | Chrome, Obsidian, Figma, Claude, ChatGPT, Pocket Casts |
| **macOS Prefs** | Fast key repeat, no natural scroll, Finder improvements, Dock config |
| **Desktop** | Custom wallpaper (fit to screen, black background) |

## What the Setup Script Does

1. Installs **Homebrew** (if missing)
2. Installs all packages from **Brewfile**
3. **Symlinks** config files to `~/.config/`
4. Sets **Fish** as default shell
5. Starts **AutoRaise** service and **Aerospace**
6. Configures the **Dock** (apps, autohide, size, magnification)
7. Imports **Ice** preferences and adds to login items
8. Sets **wallpaper** (fit to screen, black background)
9. Applies **macOS defaults** (keyboard, trackpad, Finder, disable native space-switching)

## Structure

```
.
├── Brewfile                          # Homebrew taps, formulae & casks
├── setup.sh                          # Main bootstrap script
├── .gitignore
├── config/
│   ├── aerospace/aerospace.toml      # Tiling WM (vim keys, workspaces, gaps)
│   ├── AutoRaise/config              # Focus follows mouse
│   ├── atuin/config.toml             # Shell history sync
│   ├── borders/bordersrc             # Active window border (Catppuccin blue)
│   ├── btt/exported_triggers.bttpreset  # Trackpad gestures → Aerospace
│   ├── fish/config.fish              # Shell (starship, zoxide, atuin, aliases)
│   ├── gh/config.yml                 # GitHub CLI (pr checkout alias)
│   ├── ghostty/config.ghostty        # Terminal (font, theme, splits, keybinds)
│   ├── git/gitconfig                 # User config + global ignore
│   ├── git/gitignore_global          # .DS_Store, .env, swap files
│   └── ice/com.jordanbaird.Ice.plist # Menu bar layout
├── scripts/
│   ├── set_wallpaper.py              # Wallpaper with fit + black bg
│   ├── setup_dock.py                 # Dock apps and appearance
│   └── setup_ssh.sh                  # SSH key generation + GitHub
└── wallpaper/desktop.png             # Desktop background image
```

## Key Bindings

### Aerospace (Window Management)
| Binding | Action |
|---------|--------|
| `Alt + H/J/K/L` | Focus left/down/up/right |
| `Alt + Shift + H/J/K/L` | Move window |
| `Alt + 1-9` | Switch workspace |
| `Alt + Shift + 1-9` | Move window to workspace |
| `Alt + Left/Right` | Prev/next workspace |
| `Alt + F` | Fullscreen |
| `Alt + /` | Toggle horizontal/vertical tiles |
| `Alt + Shift + Space` | Toggle floating |
| `Alt + Shift + C` | Reload config |

### Ghostty (Terminal)
| Binding | Action |
|---------|--------|
| `Cmd + D` | Split right |
| `Cmd + Shift + D` | Split down |
| `Cmd + W` | Close split |
| `Cmd + Shift + Enter` | Zoom split |
| `Cmd + Alt + Arrows` | Navigate splits |
| `` Cmd + ` `` | Quick terminal (global) |

### Trackpad Gestures (BetterTouchTool)
| Gesture | Action |
|---------|--------|
| 3/4-finger swipe right | Next workspace |
| 3/4-finger swipe left | Prev workspace |

## Syncing Changes

After tweaking a config:
```bash
cd MBPasCODE
git add -A && git commit -m "Update configs"
git push
```

On another machine:
```bash
cd MBPasCODE && git pull && ./setup.sh
```

