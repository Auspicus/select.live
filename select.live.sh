#!/bin/bash

# get-cookie.sh

# Function to get current timestamp in milliseconds
get_timestamp() {
  date +%s%N | cut -b1-13
}

# Function to get auth cookies
get_cookies() {
  local email="$1"
  local password="$2"

  if [ -z "$email" ] || [ -z "$password" ]; then
    echo "Usage: $0 get_cookies <email> <password>"
    exit 1
  fi

  curl -X POST -s -D - "https://select.live/login" \
    --data-raw "email=$email&pwd=$password" -o /dev/null \
  | grep -i '^Set-Cookie:' \
  | sed -E 's/Set-Cookie: ([^;]+);.*/\1/' \
  | tr '\n' '; ' \
  | sed 's/; $//'
}

# Function to get battery state of charge
get_battery_soc() {
  local email="$1"
  local password="$2"

  if [ -z "$email" ] || [ -z "$password" ]; then
    echo "Usage: $0 get_battery_soc <email> <password>"
    exit 1
  fi

  local cookies
  cookies=$(get_cookies "$email" "$password")
  local timestamp
  timestamp=$(get_timestamp)
  local url="https://select.live/systems/list/owner?_=$timestamp"

  curl -s -H "accept: application/json" -H "Cookie: $cookies" "$url" \
    | jq -j '.systems[0].last.battery_soc'
}

# Entry point
if [ $# -lt 1 ]; then
  echo "Usage: $0 <function> [args...]"
  echo "Available functions: get_cookies, get_battery_soc"
  exit 1
fi

command="$1"
shift

case "$command" in
  get_cookies)
    get_cookies "$@"
    ;;
  get_battery_soc)
    get_battery_soc "$@"
    ;;
  *)
    echo "Unknown command: $command"
    echo "Available functions: get_cookies, get_battery_soc"
    exit 1
    ;;
esac
