#!/usr/bin/env bash
set -e
mysqldump -u $MYSQL_USERNAME -$MYSQL_PASSWORD -h mysql $MYSQL_DATABASE > database.sql
gzip database.sql
aws s3api put-object --bucket $AWS_BUCKET --key $PREFIX/database.sql.gz --body database.sql.gz
rm database.sql.gz
