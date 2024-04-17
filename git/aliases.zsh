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
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

function gbdn() {
  default_branch=$(git config remote.origin.defaultbranch)
  if [ $? -ne 0 ]; then
    default_branch=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
    echo "setting default branch to $default_branch"
    git config --local remote.origin.defaultbranch $default_branch
  fi

  git checkout $default_branch && git pull && git bclean $default_branch;
}
