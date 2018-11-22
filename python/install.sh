# Check for pip
if test $(which pip3)
then
  # Upgrade pip
  pip3 install --upgrade pip
  pip3 install -r requirements.txt
fi
