#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\[\e[1;36m\]\u\[\e[m\]@\[\e[1;32m\]\h \[\e[1;31m\]\W\[\e[m\]]$ '

if [[ -z $DISPLAY ]] && [[ "$(tty)" = /dev/tty1 ]]; then
	mv ~/.swaylog/output ~/.swaylog/output.old
	mv ~/.swaylog/error ~/.swaylog/error.old
	sleep .3
	exec sway >~/.swaylog/output 2>~/.swaylog/error
else
	neofetch --speed_shorthand on --cpu_temp C --cpu_cores logical --gtk_shorthand on
fi

export PATH="$PATH:/home/sheepymeh/.local/bin"