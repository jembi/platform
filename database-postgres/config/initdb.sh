#!/bin/bash

# Wait for PostgreSQL to be ready
until pg_isready -h postgres-1 -p 5432 -U admin
do
    echo "Waiting for PostgreSQL to be ready..."
    sleep 1
done

# Create a new PostgreSQL database
psql -h postgres -p 5432 -U admin -c "CREATE DATABASE ${DATABASES};"

echo "Database '${DATABASES}' created successfully."
