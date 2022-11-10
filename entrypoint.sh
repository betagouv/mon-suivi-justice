#!/bin/sh -l
set -ex

rm -rf /app/tmp/pids/server.pid

exec "$@"
