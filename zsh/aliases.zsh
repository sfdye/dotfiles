alias reload!='. ~/.zshrc'

# shortcut for editing dotfiles itself
alias ed='cd $ZSH && e .'

alias cls='clear' # Good 'ol Clear Screen command
alias ls='lsd'
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
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

# Toggle hide/show
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# bat
alias cat='bat --style=plain,changes'

# leetcode-cli
alias lc='leetcode'
