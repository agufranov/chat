ssh user@srv << "ENDSSH"
  cd ~/chat
  npm install
  git fetch --all
  git reset --hard origin/master
  git pull origin master
  gulp
ENDSSH
