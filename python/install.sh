# Check for pip
if test $(which pip)
then
  # Upgrade pip
  pip install --upgrade pip
  pip install -r requirements.txt
fi
