#!/bin/bash
# Starts up postgresql within the container.

# Stop on error
set -e

DATA_DIR=/data

if [[ -e /firstrun ]]; then
  source /scripts/first_run.sh
else
  source /scripts/normal_run.sh
fi

wait_for_postgres_and_run_post_start_action() {
  # Wait for postgres to finish starting up first.
  while [[ ! -e /var/run/postgresql/9.3-main.pid ]] ; do
      inotifywait -q -e create /var/run/postgresql/ >> /dev/null
  done

  post_start_action
}

pre_start_action

wait_for_postgres_and_run_post_start_action &

# Start PostgreSQL
echo "Starting PostgreSQL..."
sudo -u postgres /usr/lib/postgresql/9.3/bin/postgres -D $DATA_DIR --config-file=/etc/postgresql/9.3/main/postgresql.conf
