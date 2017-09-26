alias reload!='. ~/.zshrc'

# alias cls='clear' # Good 'ol Clear Screen command

alias l='ls -lrt'
alias ll='ls -lrta'

alias h='history'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~' # `cd` is probably faster to type though
alias -- -='cd -'

alias grep='grep --color=auto'

# My IP
alias myip="ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print \$2}'"
