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

alias composer='php -d memory_limit=-1 /usr/local/bin/composer'
alias phpunit='./vendor/bin/phpunit'

# Docker
export DOCKER_SYNC_STRATEGY=native_osx
alias dsh='docker-compose exec web /sbin/setuser www-data /bin/bash'
alias dss='docker-sync-stack'
alias dc='docker-compose'
alias dpull='docker pull sonarsoftware/sonar-base-develop:latest'

