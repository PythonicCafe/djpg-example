#!/bin/bash
# Creates a CSV file with ~10.7M rows and add to two tables, testing fastupdate (on|off) impact on ingestion and index
# size.
# Installs a view on the database to calculate size report: <https://gist.github.com/turicas/afcde268b9616cfb6b9d69a7831d77ec#file-postgres_table_size_report-sql-L9>
# Delete tables and CSVs afterwards (cleanup and to avoid autovacuum interfering in the process)

if [[ -z $DATABASE_URL ]]; then
  echo "ERROR: requires a postgres database available at \$DATABASE_URL"
  exit 1
fi
if [[ ! $(id -u) -eq 0 ]]; then
  echo "ERROR: requires to be run as root (for sync/drop caches)"
  exit 2
fi

originalCsvFilename="book-lines.csv"
csvFilename="repeated-book-lines.csv"
copyCmdOff="\\copy test_fastupdate_off (\"line\") FROM STDIN WITH (DELIMITER ',', QUOTE '\"', ENCODING 'UTF8', FORCE_NULL (\"line\") , FORMAT CSV)"
copyCmdOn="\\copy test_fastupdate_on (\"line\") FROM STDIN WITH (DELIMITER ',', QUOTE '\"', ENCODING 'UTF8', FORCE_NULL (\"line\") , FORMAT CSV)"
sqlSizeReportUrl="https://gist.githubusercontent.com/turicas/afcde268b9616cfb6b9d69a7831d77ec/raw/1b52371b40ba8b724e1eb86248fcd874ead281a9/postgres_table_size_report.sql"
sqlSizeReport="size_report.sql"

echo "Downloading size_report view code and creating it"
rm -rf "$sqlSizeReport"
wget -O - "$sqlSizeReportUrl" \
  | grep -Ev '^--' \
  | grep -v 'VACUUM ANALYZE' \
  | grep -v "SELECT \* FROM size_report" >> "$sqlSizeReport"
cat "$sqlSizeReport" | psql "$DATABASE_URL" --no-psqlrc

echo "Downloading books"
python generate_book_csv.py

# Requires 600MB+
echo "Creating ${csvFilename}"
rm -rf "$csvFilename"
for i in $(seq 100); do
  cat "$originalCsvFilename" >> "$csvFilename"
done

# Time: 0m20.018s
# table            | test_fastupdate_on
# row_estimate     | 1.0698997e+07
# total_size       | 924 MB
# index_size       | 15 MB
# toast_size       | 8192 bytes
# table_size       | 909 MB
# table_size_ratio | 0.98
# avg_row_size     | 90.57
# total_bytes      | 969039872
# index_bytes      | 15851520
# toast_bytes      | 8192
# table_bytes      | 953180160
echo "First test: fastupdate = on"
psql "$DATABASE_URL" --no-psqlrc -c "DROP TABLE IF EXISTS test_fastupdate_on ; CREATE TABLE test_fastupdate_on (line TEXT)"
psql "$DATABASE_URL" --no-psqlrc -c "CREATE INDEX ON test_fastupdate_on USING gin (to_tsvector('portuguese', 'line')) WITH (fastupdate = on)"
echo "Inserting with fastupdate = on"
time cat "$csvFilename" | psql "$DATABASE_URL" --no-psqlrc -c "$copyCmdOn"
psql "$DATABASE_URL" --no-psqlrc -c "VACUUM ANALYZE test_fastupdate_on"
psql "$DATABASE_URL" --no-psqlrc --expanded --pset="pager=0" -c "SELECT * FROM size_report WHERE \"table\" = 'test_fastupdate_on'"
psql "$DATABASE_URL" --no-psqlrc -c "DROP TABLE test_fastupdate_on"
# Delete table afterwards to avoid autovacuum interfering

echo "Cleaning up and flushing"
psql "$DATABASE_URL" --no-psqlrc -c "CHECKPOINT"
sync
sh -c 'echo 3 > /proc/sys/vm/drop_caches'
sleep 30

# Time: 0m24.057s
# table            | test_fastupdate_off
# row_estimate     | 1.069847e+07
# total_size       | 923 MB
# index_size       | 14 MB
# toast_size       | 8192 bytes
# table_size       | 909 MB
# table_size_ratio | 0.98
# avg_row_size     | 90.49
# total_bytes      | 968122368
# index_bytes      | 14934016
# toast_bytes      | 8192
# table_bytes      | 953180160
echo "Second test: fastupdate = off"
psql "$DATABASE_URL" --no-psqlrc -c "DROP TABLE IF EXISTS test_fastupdate_off ; CREATE TABLE test_fastupdate_off (line TEXT)"
psql "$DATABASE_URL" --no-psqlrc -c "CREATE INDEX ON test_fastupdate_off USING gin (to_tsvector('portuguese', 'line')) WITH (fastupdate = off)"
echo "Inserting with fastupdate = off"
time cat "$csvFilename" | psql "$DATABASE_URL" --no-psqlrc -c "$copyCmdOff"
psql "$DATABASE_URL" --no-psqlrc -c "VACUUM ANALYZE test_fastupdate_off"
psql "$DATABASE_URL" --no-psqlrc --expanded --pset="pager=0" -c "SELECT * FROM size_report WHERE \"table\" = 'test_fastupdate_off'"
psql "$DATABASE_URL" --no-psqlrc -c "DROP TABLE test_fastupdate_off"

rm "$originalCsvFilename" "$csvFilename"
