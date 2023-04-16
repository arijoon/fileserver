#!/bin/bash

while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

app=/opt/app/${APP_NAME}/bin/${APP_NAME}

# Create database if it doesn't exist.
# if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
  # echo "Database $PGDATABASE does not exist. Creating..."
#
  # echo "Database $PGDATABASE created."
# fi

$app eval FileServer.Release.migrate

exec $app start