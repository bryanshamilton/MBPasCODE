#!/usr/bin/env bash
set -euo pipefail

echo "🔑 SSH Key Setup"
echo ""

SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
  echo "✅ SSH key already exists at $SSH_KEY"
else
  echo "Generating a new Ed25519 SSH key..."
  read -p "Email for SSH key (enter for git config email): " email
  if [ -z "$email" ]; then
    email=$(git config --global user.email)
  fi
  ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY"
  echo ""
  echo "✅ Key generated at $SSH_KEY"
fi

# Start ssh-agent and add key
eval "$(ssh-agent -s)" > /dev/null
ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null

# Ensure SSH config uses keychain
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "UseKeychain" "$SSH_CONFIG" 2>/dev/null; then
  mkdir -p "$HOME/.ssh"
  cat >> "$SSH_CONFIG" << 'EOF'

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
  echo "✅ SSH config updated to use Keychain"
fi

echo ""
echo "Adding SSH key to GitHub..."
if gh auth status &>/dev/null; then
  gh ssh-key add "$SSH_KEY.pub" --title "$(scutil --get ComputerName) $(date +%Y-%m-%d)" 2>/dev/null && \
    echo "✅ SSH key added to GitHub" || \
    echo "⚠️  Key may already be added to GitHub"
else
  echo "⚠️  Not logged into gh CLI. Run 'gh auth login' first, then:"
  echo "   gh ssh-key add $SSH_KEY.pub"
fi

echo ""
echo "🎉 SSH setup complete!"
