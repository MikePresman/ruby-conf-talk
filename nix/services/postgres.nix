{ coreutils
, postgresql
}:

{
  name = "postgres";
  ansiColor = "33";

  packages = [
    coreutils # sleep
    postgresql
  ];

  env = ''
    wait_for_postgres() {
      until psql -c '\q' 2> /dev/null; do
        sleep 0.2
      done
    }

    database_exists() {
      if [ "$(psql -qtAc "SELECT 1 FROM pg_database WHERE datname = '$1'")" == "1" ]; then
        exit 0
      else
        exit 1
      fi
    }

    create_database() {
      psql -c "CREATE DATABASE $1;"
    }
  '';

  setup = ''
    if [ ! -d "$PGDATA" ]; then
      echo "== Creating postgres database cluster =="
      initdb --username="$PGUSER" --pwfile=<(echo "$PGPASSWORD")
      echo "== postgres Database cluster created =="
    fi
  '';

  # Don't try to create a unix socket
  # We only use TCP sockets and some systems require root permissions for unix sockets


run = ''
  # Start postgres in the foreground and capture logs
  postgres -c unix_socket_directories= -c timezone=UTC -c fsync=off -c synchronous_commit=off -c full_page_writes=off 2>&1 | tee /tmp/postgres.log &

  sleep 1  # Give PostgreSQL time to fail if needed

  # Check for "Address already in use" error in the logs
  if grep -q "could not bind IPv6 address" /tmp/postgres.log || grep -q "could not bind IPv4 address" /tmp/postgres.log; then
    echo "ERROR: PostgreSQL failed to start because the address is already in use."
    echo "Another process may already be using port 5432."
    ps -a | grep '^ *[0-9]* *\(/nix/.*\)' | awk '{print $1}' | xargs kill
    exit 1
  fi

  if ! $(database_exists $PGDATABASE); then
    # Wait for postgres to be ready
    wait_for_postgres() {
      until psql -U $PGUSER -h $PGHOST -p $PGPORT -c '\q' 2>/dev/null; do
        echo "Waiting for postgres to be ready..."
        sleep 0.5
        createdb -U $PGUSER -h $PGHOST -p $PGPORT $PGDATABASE
      done
      echo "Database $PGDATABASE created"
    }
  fi

  # Wait for postgres readiness
  wait_for_postgres
  
  echo "Postgres is up"
'';
}
