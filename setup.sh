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
link_config "$DOTFILES_DIR/config/gh/config.yml"            "$HOME/.config/gh/config.yml"

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

# ─── App Preferences ───────────────────────────────────────────────────────────
echo ""
echo "🧊 Importing Ice (menu bar) preferences..."
# Quit Ice if running so preferences take effect cleanly
killall Ice 2>/dev/null || true
sleep 1
defaults import com.jordanbaird.Ice "$DOTFILES_DIR/config/ice/com.jordanbaird.Ice.plist"
open -a Ice
echo "  ✅ Ice preferences imported and app started"

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

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Disable natural scrolling (optional - comment out if you prefer natural)
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo ""
echo "✨ Setup complete! Please restart your terminal (or log out/in) for all changes to take effect."
