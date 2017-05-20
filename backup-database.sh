#!/usr/bin/env bash
set -e
mysqldump -u $USERNAME -$PASSWORD -h mysql $DATABASE > database.sql
gzip database.sql
aws s3api put-object --bucket $BUCKET --key $PREFIX/database.sql.gz --body database.sql.gz
rm database.sql.gz
