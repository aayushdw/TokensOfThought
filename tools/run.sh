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

wait_for_port() {
  local port=$1
  local retries=10
  while lsof -iTCP:"$port" -sTCP:LISTEN -t >/dev/null 2>&1; do
    if [ $retries -le 0 ]; then
      echo "> Port $port still in use. Killing remaining processes..."
      lsof -iTCP:"$port" -sTCP:LISTEN -t | xargs kill -9 2>/dev/null
      sleep 1
      return
    fi
    retries=$((retries - 1))
    sleep 1
  done
}

while true; do
  eval "$command" || true
  echo -e "\n> Server exited unexpectedly. Restarting...\n"
  wait_for_port 4000
  wait_for_port 35729
done
