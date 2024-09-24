#!/bin/bash

time rows pgexport --is-query "$DATABASE_URL" "$(cat ../sql/empresa.sql)" "/data/empresa.csv.gz"
