#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 MBPasCODE - Setting up your Mac..."
echo ""

# ─── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "✅ Homebrew already installed"
fi

# ─── Brewfile ──────────────────────────────────────────────────────────────────
echo "📦 Installing packages from Brewfile..."
if ! brew bundle --file="$DOTFILES_DIR/Brewfile"; then
  echo ""
  echo "⚠️  Some Brewfile items failed (see above). Continuing with the rest of setup..."
  echo ""
fi

# ─── Symlink configs ──────────────────────────────────────────────────────────
echo ""
echo "🔗 Symlinking config files..."

link_config() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "  ⚠️  Backing up existing $dest → ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi
  ln -s "$src" "$dest"
  echo "  ✅ $dest → $src"
}

link_config "$DOTFILES_DIR/config/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"
link_config "$DOTFILES_DIR/config/ghostty/config.ghostty"   "$HOME/.config/ghostty/config.ghostty"
link_config "$DOTFILES_DIR/config/fish/config.fish"         "$HOME/.config/fish/config.fish"
link_config "$DOTFILES_DIR/config/borders/bordersrc"        "$HOME/.config/borders/bordersrc"
link_config "$DOTFILES_DIR/config/atuin/config.toml"        "$HOME/.config/atuin/config.toml"
link_config "$DOTFILES_DIR/config/AutoRaise/config"         "$HOME/.config/AutoRaise/config"
link_config "$DOTFILES_DIR/config/git/gitconfig"            "$HOME/.gitconfig"
link_config "$DOTFILES_DIR/config/git/gitignore_global"     "$HOME/.config/git/gitignore_global"
link_config "$DOTFILES_DIR/config/gh/config.yml"            "$HOME/.config/gh/config.yml"

# ─── Code directory structure ──────────────────────────────────────────────────
echo ""
echo "📁 Setting up ~/Code directory structure..."
mkdir -p "$HOME/Code"/{arrow,personal,labs,forks,archive,ai}
if [ ! -f "$HOME/Code/README.md" ]; then
  cat > "$HOME/Code/README.md" <<'EOF'
# Local Code Organization
- arrow/ — Arrow work projects and internal tooling
- personal/ — personal repos and side projects
- ai/ — generated experiments, Claude Code workspaces, prompts, agents
- labs/ — experiments, spikes, throwaway tests
- forks/ — cloned third-party repos
- archive/ — old local projects kept for reference
EOF
  echo "  ✅ Created ~/Code with README"
else
  echo "  ✅ ~/Code already exists"
fi

# ─── Set Fish as default shell ─────────────────────────────────────────────────
FISH_PATH="/opt/homebrew/bin/fish"
if ! grep -q "$FISH_PATH" /etc/shells; then
  echo ""
  echo "🐟 Adding Fish to /etc/shells (requires sudo)..."
  echo "$FISH_PATH" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$FISH_PATH" ]; then
  echo "🐟 Setting Fish as default shell..."
  chsh -s "$FISH_PATH"
else
  echo "✅ Fish is already the default shell"
fi

# ─── Start services ────────────────────────────────────────────────────────────
echo ""
echo "🚀 Starting services..."

# AutoRaise - focus follows mouse
brew services start autoraise 2>/dev/null && echo "  ✅ AutoRaise started" || echo "  ⚠️  AutoRaise failed to start"

# Aerospace - tiling window manager (starts borders via after-startup-command)
if ! pgrep -q AeroSpace; then
  echo "  🪟 Starting Aerospace..."
  open -a AeroSpace
  echo "  ✅ Aerospace started (borders will follow)"
else
  echo "  ✅ Aerospace already running"
fi

# ─── Dock ──────────────────────────────────────────────────────────────────────
echo ""
python3 "$DOTFILES_DIR/scripts/setup_dock.py"

# ─── VS Code ───────────────────────────────────────────────────────────────────
echo ""
echo "💻 Setting up VS Code..."

# Symlink settings.json
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER_DIR"
link_config "$DOTFILES_DIR/config/code/settings.json" "$VSCODE_USER_DIR/settings.json"

# Install extensions
if command -v code &>/dev/null; then
  echo "  📦 Installing VS Code extensions..."
  grep -v '^#' "$DOTFILES_DIR/config/code/extensions.txt" | grep -v '^$' | while read -r ext; do
    code --install-extension "$ext" --force 2>/dev/null && echo "    ✅ $ext" || echo "    ⚠️  Failed: $ext"
  done
else
  echo "  ⚠️  'code' CLI not found — open VS Code and run 'Shell Command: Install code command in PATH'"
fi

# ─── App Preferences ───────────────────────────────────────────────────────────
echo ""
echo "🧊 Importing Ice (menu bar) preferences..."
# Quit Ice if running so preferences take effect cleanly
osascript -e 'tell application "Ice" to quit' 2>/dev/null || true
sleep 1
defaults import com.jordanbaird.Ice "$DOTFILES_DIR/config/ice/com.jordanbaird.Ice.plist"
open -a Ice

# Ensure Ice starts at login
if ! osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | grep -q "Ice"; then
  osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Ice.app", hidden:false}' 2>/dev/null
  echo "  ✅ Ice added to login items"
else
  echo "  ✅ Ice already in login items"
fi

# ─── Wallpaper ─────────────────────────────────────────────────────────────────
echo ""
echo "🖼️  Setting desktop wallpaper (fit to screen, black background)..."
python3 "$DOTFILES_DIR/scripts/set_wallpaper.py" "$DOTFILES_DIR/wallpaper/desktop.png"

# ─── macOS Defaults ────────────────────────────────────────────────────────────
echo ""
echo "⚙️  Applying macOS preferences..."

# Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys (enable key repeat everywhere)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Trackpad: disable natural scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Trackpad: disable native swipe between Spaces (handled by BTT + Aerospace)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 0
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false

# Trackpad: four-finger vertical swipe (Mission Control / App Exposé)
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2

# Trackpad: two-finger double-tap (smart zoom)
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "  ✅ macOS preferences applied"

echo ""
echo "✨ Setup complete! Please restart your terminal (or log out/in) for all changes to take effect."
echo ""
echo "Optional next steps:"
echo "  • Run 'scripts/setup_ssh.sh' to generate and add SSH key to GitHub"
if [ -f "$DOTFILES_DIR/config/btt/Default.bttpreset" ]; then
  echo "  • Open BetterTouchTool → Presets → Import to load config/btt/Default.bttpreset"
fi
