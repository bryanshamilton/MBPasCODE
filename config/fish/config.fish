eval "$(/opt/homebrew/bin/brew shellenv)"

fish_vi_key_bindings

starship init fish | source
zoxide init fish | source
atuin init fish | source

alias ll="eza -al --icons"
alias ls="eza --icons"
alias cat="bat"
alias copilot="gh copilot"

set -gx EDITOR "code"

# Navigation abbreviations
abbr -a ccode 'cd ~/Code'
abbr -a carrow 'cd ~/Code/arrow'
abbr -a cpersonal 'cd ~/Code/personal'
abbr -a clabs 'cd ~/Code/labs'
abbr -a cai 'cd ~/Code/ai'

if status is-interactive
    # Commands to run in interactive sessions can go here
end
