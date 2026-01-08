#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Setup the database
rails db:create db:migrate

# Then exec the container's main process
exec "$@" 