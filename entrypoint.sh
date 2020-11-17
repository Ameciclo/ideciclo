#!/bin/bash
# Docker entrypoint script.
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
  echo "Database $PGDATABASE does not exist. Creating..."
  mic ecto.create
  mix ecto.migrate
  mix run priv/repo/seeds.exs
  echo "Database $PGDATABASE created and seeded."
fi

exec mix phx.server