alias reload!='. ~/.zshrc'

# shortcut for editing dotfiles itself
alias ed='cd $ZSH && e .'

alias cls='clear' # Good 'ol Clear Screen command
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

# Python 3
alias python='/usr/local/bin/python3'
alias python2='/usr/local/bin/python2'

alias pip="/usr/local/bin/pip3"
alias pip2="/usr/local/bin/pip"

# My IP
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

# Toggle hide/show
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# colorcat
if [[ $(uname -s) == "Darwin" ]]
then
  alias cat=ccat
fi
