#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\[\e[1;36m\]\u\[\e[m\]@\[\e[1;32m\]\h \[\e[1;31m\]\W\[\e[m\]]$ '

if [[ -z $DISPLAY ]] && [[ "$(tty)" = /dev/tty1 ]]; then
	export JAVA_TOOL_OPTIONS="-Dawt.toolkit.name=WLToolkit"
	export PATH="$PATH:$HOME/.local/bin"
	export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
	systemd-inhibit --what=handle-lid-switch sleep .5 &
	exec systemd-cat --identifier=sway sway
fi

unset JAVA_TOOL_OPTIONS
fastfetch

venv() {
	if [ -z "$1" ]; then
		if [ -d venv ]; then
			venv_to_activate=venv
		elif [ -d .venv ]; then
			venv_to_activate=.venv
		else
			venv_paths=$(find . -maxdepth 2 -type d -name bin)
			for venv_path in $venv_paths; do
				if [ -f "$venv_path/activate" ]; then
					venv_to_activate="$(dirname $venv_path)"
					break
				fi
			done
		fi
	else
		if [ -f "$1/bin/activate" ]; then
			venv_to_activate="$1"
		elif [ -d "$1" ]; then
			echo "$1 is not a venv"
			return 1
		fi
	fi

	if [ -z "$venv_to_activate" ]; then
		venv_path=${1:-venv}
		echo "Creating venv in $venv_path"
		python -m venv --system-site-packages --prompt "$(basename $(dirname $PWD/$venv_path))/$(basename $venv_path)" $venv_path
		venv_to_activate=$venv_path
	fi
	source "$venv_to_activate/bin/activate"
	unset venv_to_activate
}
