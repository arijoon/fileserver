git pull
if docker-compose build; then
  docker-compose down
  docker-compose up -d
fi
