alias ga='git add -A'
# Remove `+` and `-` from start of diff lines; just rely upon color.
alias gd='git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='gh repo view -w'
alias pc='gh pr create -w'  # create pull request on web
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias gac='git add -A && git commit'

