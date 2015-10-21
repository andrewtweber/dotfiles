# Search directories recursively, show colors
export GREP_OPTIONS="--directories=recurse --color=auto"

# Expand tabs as 4 spaces
export LESS="-x4"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Make every file I create group writeable
umask g+w

# Bash prompt
source ~/.bash_prompt

# Enable colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
