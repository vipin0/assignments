#!/usr/bin/env bash

source lamp-config.sh
set -e
date=$(date "+%B-%d-%Y")
filename="$DB_NAME-$date-backup"
mysqldump -u $DB_USER -p$DB_PASSWORD --databases $DB_NAME > /tmp/$filename.sql;
cd /tmp
tar -czf /opt/backups/$filename.tar.gz $filename.sql
rm -f $filename.sql

