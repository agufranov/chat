ssh user@srv << "ENDSSH"
  cd ~/chat
  git fetch --all
  git reset --hard origin/master
  git pull origin master
  npm install
  node build/app.js
ENDSSH
