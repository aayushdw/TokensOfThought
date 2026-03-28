#!/usr/bin/env bash
#
# Run jekyll serve and then launch the site

prod=false
command="bundle exec jekyll s -l"
host="127.0.0.1"

help() {
  echo "Usage:"
  echo
  echo "   bash /path/to/run [options]"
  echo
  echo "Options:"
  echo "     -H, --host [HOST]    Host to bind to."
  echo "     -p, --production     Run Jekyll in 'production' mode."
  echo "     -h, --help           Print this help information."
}

while (($#)); do
  opt="$1"
  case $opt in
  -H | --host)
    host="$2"
    shift 2
    ;;
  -p | --production)
    prod=true
    shift
    ;;
  -h | --help)
    help
    exit 0
    ;;
  *)
    echo -e "> Unknown option: '$opt'\n"
    help
    exit 1
    ;;
  esac
done

command="$command -H $host"

if $prod; then
  command="JEKYLL_ENV=production $command"
fi

if [ -e /proc/1/cgroup ] && grep -q docker /proc/1/cgroup; then
  command="$command --force_polling"
fi

echo -e "\n> $command\n"

trap 'echo -e "\n> Shutting down..."; exit 0' INT TERM

kill_port() {
  local port=$1
  local pids
  pids=$(lsof -iTCP:"$port" -sTCP:LISTEN -t 2>/dev/null)
  if [ -n "$pids" ]; then
    echo "> Port $port in use (PIDs: $pids). Killing..."
    echo "$pids" | xargs kill -9 2>/dev/null
    # Wait until the port is actually free
    local retries=10
    while lsof -iTCP:"$port" -sTCP:LISTEN -t >/dev/null 2>&1; do
      if [ $retries -le 0 ]; then
        echo "> ERROR: Port $port still in use after kill. Exiting."
        exit 1
      fi
      retries=$((retries - 1))
      sleep 1
    done
  fi
}

# Clean up ports before first launch
kill_port 4000
kill_port 35729

crash_count=0
max_crashes=5

while true; do
  eval "$command"
  exit_code=$?

  # If Jekyll exited cleanly (e.g. user stopped it), don't restart
  if [ $exit_code -eq 0 ]; then
    break
  fi

  crash_count=$((crash_count + 1))
  if [ $crash_count -ge $max_crashes ]; then
    echo -e "\n> Server crashed $crash_count times in a row. Stopping to avoid loop."
    echo "> Fix the issue and re-run the script."
    exit 1
  fi

  echo -e "\n> Server exited unexpectedly (crash $crash_count/$max_crashes). Restarting...\n"
  kill_port 4000
  kill_port 35729
done
