eval "$(/opt/homebrew/bin/brew shellenv)"

fish_vi_key_bindings

starship init fish | source
zoxide init fish | source
atuin init fish | source

alias ll="eza -al --icons"
alias ls="eza --icons"
alias cat="bat"

set -gx EDITOR "code"

if status is-interactive
    # Commands to run in interactive sessions can go here
end
