#!/bin/bash

# Define variables
HOST="localhost"
DATABASE="goldenoasisdb"
USER="postgres"
PORT="5432"
SQL_FILE="database.sql"

# Drop the database if it exists
psql -h $HOST -U $USER -p $PORT -c "DROP DATABASE IF EXISTS $DATABASE;"

# Create the database
psql -h $HOST -U $USER -p $PORT -c "CREATE DATABASE $DATABASE;"

# Run psql command to execute SQL script
psql -h $HOST -d $DATABASE -U $USER -p $PORT < $SQL_FILE

