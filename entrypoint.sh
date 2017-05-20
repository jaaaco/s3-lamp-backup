#!/usr/bin/env bash

echo "Restoring latest database"
aws s3api get-object --bucket $AWS_BUCKET --key $PREFIX/database.sql.gz database.sql.gz
if [ -e database.sql.gz ] ; then
    gunzip database.sql.gz
    echo "DROP DATABASE IF EXISTS $MYSQL_DATABASE" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -h mysql
    echo "CREATE DATABASE $MYSQL_DATABASE DEFAULT CHARACTER SET utf8 COLLATE utf8_polish_ci;" | mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -h mysql
    mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -h mysql $MYSQL_DATABASE < database.sql
    echo "Cleaning up..."
    rm database.sql
else
    echo "--- No database backup to restore from"
fi

if [ ! -e /files/_restored ] ; then
    echo "Restoring latest files"
    aws s3api get-object --bucket $AWS_BUCKET --key $PREFIX/files.tar.gz files.tar.gz
    if [ -e files.tar.gz ] ; then
        tar zxf files.tar.gz
        touch /files/_restored
        echo "Cleaning up..."
        rm files.tar.gz
    else
        echo "--- No files backup to restore"
    fi
else
    echo "File restore omitted - files present"
fi

# default cron schedule: 3am on monday
CRON_SCHEDULE=${CRON_SCHEDULE:-0 3 * * *}

LOGFIFO='/var/log/cron.fifo'

if [[ ! -e "$LOGFIFO" ]]; then
    touch "$LOGFIFO"
fi

CRON_ENV="$CRON_ENV\nAWS_ACCESS_KEY_ID='$AWS_ACCESS_KEY_ID'"
CRON_ENV="$CRON_ENV\nAWS_SECRET_ACCESS_KEY='$AWS_SECRET_ACCESS_KEY'"
CRON_ENV="$CRON_ENV\nBUCKET='$AWS_BUCKET'"

echo -e "$CRON_ENV\n$CRON_SCHEDULE /backup.sh > $LOGFIFO 2>&1" | crontab -
crontab -l
cron
tail -f "$LOGFIFO"