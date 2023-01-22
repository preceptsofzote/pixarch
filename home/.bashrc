#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='exa'
PS1='[\u@\h \W]\$ '

export VISUAL='vim'
export EDITOR=$VISUAL

export VIMINIT='source $MYVIMRC'
export MYVIMRC='~/.config/vim/.vimrc'
