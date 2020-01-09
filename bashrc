#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\e[1;36m\u\e[m@\e[1;32m\h \e[1;31m\W\e[m] $ '

neofetch --speed_shorthand on --cpu_temp C --cpu_cores logical --gtk_shorthand on

if [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
fi
