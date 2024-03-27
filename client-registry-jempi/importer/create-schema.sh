#!/bin/bash

set -e
set -u

echo "Creating dbs..."

# Creating databases
EXISTING_NOTIFICATIONS_DB=$(psql -U "${POSTGRESQL_USERNAME}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${POSTGRESQL_NOTIFICATIONS_DB}'")
if [ -z "$EXISTING_NOTIFICATIONS_DB" ]; then
  psql -U "${POSTGRESQL_USERNAME}" -d postgres -c "CREATE DATABASE ${POSTGRESQL_NOTIFICATIONS_DB}"
fi

EXISTING_AUDIT_DB=$(psql -U "${POSTGRESQL_USERNAME}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${POSTGRESQL_AUDIT_DB}'")
if [ -z "$EXISTING_AUDIT_DB" ]; then
  psql -U "${POSTGRESQL_USERNAME}" -d postgres -c "CREATE DATABASE ${POSTGRESQL_AUDIT_DB}"
fi

EXISTING_USERS_DB=$(psql -U "${POSTGRESQL_USERNAME}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${POSTGRESQL_USERS_DB}'")
if [ -z "$EXISTING_USERS_DB" ]; then
  psql -U "${POSTGRESQL_USERNAME}" -d postgres -c "CREATE DATABASE ${POSTGRESQL_USERS_DB}"
fi

psql -U "${POSTGRESQL_USERNAME}" -d "${POSTGRESQL_USERS_DB}" -a -f /conf/config-users.sql
psql -U "${POSTGRESQL_USERNAME}" -d "${POSTGRESQL_NOTIFICATIONS_DB}" -a -f /conf/config-notifications.sql
psql -U "${POSTGRESQL_USERNAME}" -d "${POSTGRESQL_AUDIT_DB}" -a -f /conf/config-audit.sql

echo "Done creating dbs."
