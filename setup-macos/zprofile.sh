#!/bin/zsh

autoload -Uz compinit
compinit

eval "$(/opt/homebrew/bin/brew shellenv)"
export EDITOR=nano
export HOMEBREW_NO_ENV_HINTS=1
export PATH="$(brew --prefix python)/libexec/bin:$PATH"
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
