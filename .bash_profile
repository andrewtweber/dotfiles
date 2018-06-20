# Expand tabs as 4 spaces
export LESS="-x4"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for git (on Mac)
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# Search directories recursively, show colors
alias grep='grep --directories=recurse --color=auto'

# Make every file I create group writeable
umask g+w

# Bash prompt
source ~/.bash_prompt

# Enable colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

alias phpunit='./vendor/bin/phpunit'

