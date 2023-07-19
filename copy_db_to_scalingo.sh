#!/bin/bash

dbclient-fetcher psql
pg_dump --clean --if-exists --format c --dbname $SCALINGO_POSTGRESQL_URL --no-owner --no-privileges --no-comments --exclude-schema 'information_schema' --exclude-schema '^pg_*' --file dump.pgsql
pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname $METABASE_POSTGRESQL_URL dump.pgsql