#.bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

RC_PATH=${HOME}/.rc.d

# Shell specific
case "${0#-}" in
    bash)
        # Don't put duplicate lines in the history. See bash(1) for more options.
        # ignoredups - ignore duplicate commands in history
        # ignorespace - ignore commands that start with a space
        # ignoreboth - shorthand for ignorespace and ignoredups
        # erasedups - duplicate lines in history are erased, most recent saved
        export HISTCONTROL=ignoreboth:erasedups

        # Set the number of commands to be kept in history
        export HISTSIZE=100000

        # Append to the history file, don't overwrite it
        shopt -s histappend

        # Check the window size after each command and, if necessary,
        # update the values of LINES and COLUMNS
        shopt -s checkwinsize
        ;;
    ksh)
        case "$-" in
            *i*)
                # Create tracked aliases, similar to "hashall" in Bash
                set -o trackall
                ;;
        esac
        ;;
esac

# Source exports
if [ -f ${RC_PATH}/.exports ]; then
    . "${RC_PATH}/.exports"
fi

# Source functions
if [ -f ${RC_PATH}/.functions ]; then
    . "${RC_PATH}/.functions"
fi

case "$-" in
    *i*)
        # For an interactive shell

        export HISTFILE=$HOME/.history

        # Check for git-completion to set up autocomplete for git
        if [ -f ~/.gitcompletion.bash ]; then
            . ~/.gitcompletion.bash
        fi

        # Enable bash completion
        if ! shopt -oq posix; then
            if [ -f /usr/share/bash-completion/bash_completion ]; then
                . /usr/share/bash-completion/bash_completion
            elif [ -f /etc/bash_completion ]; then
                . /etc/bash_completion
            fi
        fi

        set_prompt
        ;;
esac

# Source aliases
if [ -f ${RC_PATH}/.aliases ]; then
    . "${RC_PATH}/.aliases"
fi

# Source OS Specific
. "${RC_PATH}/.os_$(uname)"

# Source files in .d directory
# . files do not get reincluded
for f in $(find $RC_PATH/* 2>/dev/null); do
    . $f;
done

unset RC_PATH
