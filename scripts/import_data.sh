#!/bin/bash

set -e

function log() {
	echo "[$(date --iso=seconds)] $@";
}

db_version="$1"
model_name="$2"
csv_filename="$3"
possible_db_versions=(12 13 14 15 16)
possible_model_names=(Empresa1 Empresa2 Empresa3 Empresa4 Empresa5)

if [[ -z $csv_filename || ! " ${possible_db_versions[@]} " =~ " $db_version " || ! " ${possible_model_names[@]} " =~ " $model_name " ]]; then
	IFS='|'
	echo "ERROR - usage: $0 <db_version: ${possible_db_versions[*]}> <model_name: ${possible_model_names[*]}> <csv_filename>"
	exit 1
fi

old_database_url="$DATABASE_URL"
if [[ $db_version != 16 ]]; then
	export DATABASE_URL=$(echo $DATABASE_URL | sed "s/@db:/@db${db_version}:/")
fi

log "Ensuring migrations are run on this database"
python manage.py migrate

tablename="dataset_$(echo $model_name | tr 'A-Z' 'a-z')"
log "Truncating table $tablename"
echo "TRUNCATE TABLE $tablename" | psql --no-psqlrc "$DATABASE_URL"

log "Importing data from '${csv_filename}' into '${model_name}' model @ $DATABASE_URL"
python manage.py import_data "copy" "$model_name" "$csv_filename"

export DATABASE_URL="$old_database_url"
log "Finished!"
