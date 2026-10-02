#!/bin/zsh

autoload -Uz compinit
compinit

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$(brew --prefix python)/libexec/bin:$PATH"
export HOMEBREW_NO_ENV_HINTS=1
export EDITOR=nano
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
