PG_USER=${PG_USER:-super}
PG_PASS=${PG_PASS:-$(pwgen -s -1 16)}

pre_start_action() {
  # Echo out info to later obtain by running `docker logs container_name`
  echo "POSTGRES_USER=$PG_USER"
  echo "POSTGRES_PASS=$PG_PASS"
  echo "POSTGRES_DATA_DIR=$DATA_DIR"
  if [ ! -z $PG_DB ];then echo "POSTGRES_DB=$PG_DB";fi

  # test if DATA_DIR has content
  if [[ ! "$(ls -A $DATA_DIR)" ]]; then
      echo "Initializing PostgreSQL at $DATA_DIR"

      # Copy the data that we generated within the container to the empty DATA_DIR.
      cp -R /var/lib/postgresql/9.3/main/* $DATA_DIR
  fi

  # Ensure postgres owns the DATA_DIR
  chown -R postgres $DATA_DIR
  # Ensure we have the right permissions set on the DATA_DIR
  chmod -R 700 $DATA_DIR
}

post_start_action() {
  echo "Creating the superuser: $PG_USER"
  sudo -u postgres psql -q <<-EOF
    DROP ROLE IF EXISTS $PG_USER;
    CREATE ROLE $PG_USER WITH ENCRYPTED PASSWORD '$PG_PASS';
    ALTER USER $PG_USER WITH ENCRYPTED PASSWORD '$PG_PASS';
    ALTER ROLE $PG_USER WITH SUPERUSER;
    ALTER ROLE $PG_USER WITH LOGIN;
EOF

  # create database if requested
  if [ ! -z "$PG_DB" ]; then
    for db in $PG_DB; do
      echo "Creating database: $db"
      sudo -u postgres psql -q <<-EOF
      CREATE DATABASE $db WITH OWNER=$PG_USER TEMPLATE=template0 ENCODING='UTF8';
      GRANT ALL ON DATABASE $db TO $PG_USER
EOF
    done
  fi

  if [[ ! -z "$PG_EXTENSIONS" && ! -z "$PG_DB" ]]; then
    for extension in $PG_EXTENSIONS; do
      for db in $PG_DB; do
        echo "Installing extension for $db: $extension"
        # enable the extension for the user's database
        sudo -u postgres psql $db <<-EOF
        CREATE EXTENSION "$extension";
EOF
      done
    done
  fi

  rm /firstrun
}
