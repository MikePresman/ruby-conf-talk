{ coreutils
, redis
}:

{
  name = "redis";
  ansiColor = "31"; # red

  packages = [
    coreutils  # sleep, grep, etc.
    redis
  ];

  env = ''
    wait_for_redis() {
      until redis-cli ping 2>/dev/null | grep -q PONG; do
        echo "Waiting for Redis..."
        sleep 0.5
      done
      echo "Redis is ready"
    }
  '';

  setup = ''
    mkdir -p "$REDIS_DATA"
    mkdir -p "$REDIS_LOG"
  '';

  run = ''
    CONFIG_FILE=$REDIS_DATA/redis.conf

    # Create a minimal persistent Redis config
    cat > "$CONFIG_FILE" <<EOF
bind 127.0.0.1
port 6379
dir $REDIS_DATA
logfile $REDIS_LOG/redis.log
appendonly yes
save 900 1
save 300 10
save 60 10000
EOF

    echo "Starting Redis with config at $CONFIG_FILE"
    redis-server "$CONFIG_FILE" &

    sleep 1

    # Check for address conflict
    if grep -q "Address already in use" "$REDIS_LOG/redis.log"; then
      echo "ERROR: Redis failed to start because the address is already in use."
      ps -a | grep redis-server | awk '{print $1}' | xargs kill
      exit 1
    fi

    wait_for_redis
  '';
}
