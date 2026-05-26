# MBPasCODE

My MacBook Pro setup as code. Run the bootstrap script on a fresh Mac to get an identical environment.

## What's Included

| Category | Tools |
|----------|-------|
| **Terminal** | Ghostty (Catppuccin Mocha), Fish shell, Starship prompt |
| **Window Management** | Aerospace (tiling), Borders (active window highlight), AutoRaise |
| **CLI Tools** | atuin, bat, eza, fd, fzf, ripgrep, zoxide, direnv |
| **Dev** | git, gh, nvm, awscli, Docker Desktop, VS Code |
| **Apps** | Chrome, Obsidian, Figma, Claude, ChatGPT, BetterTouchTool, Ice |

## Quick Start

```bash
git clone https://github.com/bryanshamilton/MBPasCODE.git
cd MBPasCODE
chmod +x setup.sh
./setup.sh
```

## Structure

```
.
├── Brewfile                    # All Homebrew packages & casks
├── setup.sh                   # Bootstrap script
├── config/
│   ├── aerospace/aerospace.toml   # Tiling window manager
│   ├── AutoRaise/config           # Auto-focus follows mouse
│   ├── atuin/config.toml          # Shell history
│   ├── borders/bordersrc          # Active window borders
│   ├── fish/config.fish           # Shell config
│   ├── gh/config.yml              # GitHub CLI
│   ├── ghostty/config.ghostty     # Terminal emulator
│   └── git/gitconfig              # Git user config
└── README.md
```

## Key Bindings

### Aerospace (Window Management)
- `Alt + H/J/K/L` — Focus left/down/up/right
- `Alt + Shift + H/J/K/L` — Move window
- `Alt + 1-9` — Switch workspace
- `Alt + Shift + 1-9` — Move window to workspace
- `Alt + F` — Fullscreen
- `Alt + Shift + C` — Reload config

### Ghostty (Terminal)
- `Cmd + D` — Split right
- `Cmd + Shift + D` — Split down
- `Cmd + Alt + Arrows` — Navigate splits
- `Cmd + `` ` `` ` — Quick terminal (global)

## Updating

After changing a config locally:
```bash
cd MBPasCODE
git add -A && git commit -m "Update configs"
git push
```
