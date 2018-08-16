virtualenvwrapper='/usr/local/bin/virtualenvwrapper.sh'

if test -f $virtualenvwrapper
then
  export WORKON_HOME=$HOME/.virtualenvs
  export PROJECT_HOME=$PROJECTS
  export VIRTUALENVWRAPPER_PYTHON=$(which python3)
  source $virtualenvwrapper
fi
