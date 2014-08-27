ssh user@srv << "ENDSSH"
  cd ~/chat
  git fetch --all
  git reset --hard origin/master
  git pull origin master
  gulp
ENDSSH
