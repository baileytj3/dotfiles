#.bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines in the history. See bash(1) for more options.
# ignoredups - ignore duplicate commands in history
# ignorespace - ignore commands that start with a space
# ignoreboth - shorthand for ignorespace and ignoredups
# erasedups - duplicate lines in history are erased, most recent saved
HISTCONTROL=ignoreboth:erasedups

# Set the number of commands to be kept in history
HISTSIZE=100000
HISTFILESIZE=200000
HISTFILE=$HOME/.history

# Append to the history file, don't overwrite it
shopt -s histappend

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# Enable color support for certain commands
[[ -x "$(command -v dircolors)" ]] && eval $(dircolors)

# Check for git-completion to set up autocomplete for git
[[ -f ~/.gitcompletion.bash ]] && source ~/.gitcompletion.bash

# Enable bash completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
fi

#
# Functions
#

# Function used to add the git branch name to PS1
if [ -x "$(command -v git)" ]; then
	function parse_git_status {
		if [ -z "$NOPATHBRANCHES" ]; then
			local branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
			[[ -z $branch ]] && return
			local status=$(git status 2> /dev/null)
			local result=$branch
			[[ "$status" = *deleted:* ]] && result=${result}-
			[[ "$status" = *modified:* ]] && result=${result}*
			[[ "$status" = *Untracked\ files:* ]] && result=${result}+
			printf " [$result]"
		fi
	}
    PROMPTGIT=1
fi

# Run top showing process with given name
function ptop {
    top -p `pgrep $1 | head -20 | tr "\\n" "," | sed 's/,$//'`;
}

function set_prompt {
    # Set the prompt
    black=$(tput setaf 0)
    blue=$(tput setaf 4)
    green=$(tput setaf 2)
    red=$(tput setaf 1)
    reset=$(tput sgr0)

    # Host name color
    if [ -z "$HOSTCOLOR" ]; then
        HOSTCOLOR="${green}"
    fi

    # Branch Color
    BRANCHCOLOR="${blue}"

    # User color
    if [ $(id -ru) == '0' ]; then
        USERCOLOR="${red}"
    else
        USERCOLOR="${HOSTCOLOR}"
    fi

    # Set color prompt
    PS1="\[${black}\]["
    PS1+="\[${USERCOLOR}\]\u"
    PS1+="\[${black}\]@"
    PS1+="\[${HOSTCOLOR}\]\h"
    [[ -n PROMPTGIT ]] && PS1+="\[${BRANCHCOLOR}\]\$(parse_git_status)"
    PS1+="\[${blue}\] \w"
    PS1+="\[${black}\]]\n$ "
    PS1+="\[${reset}\]"

    export PS1
}

#
# Aliases
#

# Enable color by default for grep and variants
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias zgrep='zgrep --colour=auto'
alias zegrep='zegrep --colour=auto'
alias zfgrep='zfgrep --colour=auto'

alias ls='ls --color=auto'
alias la="ls -al"
alias ll="ls -l"

alias ..="cd .."
alias c="clear"
alias s="source ~/.bash_profile"

#
# Exports
#

EDITOR="$(command -v vim)"
if [ -z "$EDITOR" ]; then
	# ...but use vi if Vim doesn't exist.
	EDITOR=vi
fi
VISUAL=$EDITOR
export EDITOR VISUAL

# Add ~/.bin and /usr/local/sbin to path
export PATH=~/.bin:/usr/local/sbin:$PATH

# Python startup for autocomplete enabling
export PYTHONSTARTUP=~/.pythonrc


# Source local preferences at the end as not to overwrite local user prefs
[[ -f ~/.bashrc_local ]] && source ~/.bashrc_local

# Set the prompt last in case local preferences updates it
set_prompt
