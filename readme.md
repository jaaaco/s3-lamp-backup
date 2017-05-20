# Backup mysql database and project files to AWS S3

This container can be used as a part of LAMP stack to perform automatic backup / restore of mysql database and project files

## Host it works

Once container is started it checks if latest database backup is present on S3. If found it's restored to connected mysql database.
This way you can start your project anywhere without database copy present and it will be downloaded and restored in seconds.

Same happens with files in mounted /files volume unless files were previously restored.

## Usage

Example LAMP docker-dompose.yml:
```
version: '2.1'
services:
  memcached:
    restart: always
    image: memcached
  mysql:
    restart: always
    image: mysql:5.6
    environment:
      MYSQL_ROOT_PASSWORD: PUT_YOUR_PASSWORD_HERE
    healthcheck:
      test: 'timeout 2 bash -c "</dev/tcp/localhost/3306"'
      interval: 5s
      timeout: 5s
      retries: 10
    volumes:
      - db:/var/lib/mysql
  backup:
    image: jaaaco/s3-lamp-backup
    links:
      - mysql
    depends_on:
      mysql:
        condition: service_healthy
    volumes:
      - files:/files
    environment:
      AWS_ACCESS_KEY_ID: YOUR_AWS_KEY
      AWS_SECRET_ACCESS_KEY: YOUR_AWS_SECRET
      AWS_BUCKET: AWS_S3_BUCKET_NAME
      MYSQL_USERNAME: YOUR_MYSQL_USERNAME
      MYSQL_PASSWORD: YOUR_MYSQL_PASSWORD
      MYSQL_DATABASE: YOUR_DATABASE_NAME
      PREFIX: YOUR_APP_NAME_S3_BACKUP_FOLDER
  app:
    restart: always
    links:
      - memcached
      - mysql
    depends_on:
      - memcached
      - mysql
    build: app
    ports:
      - '80:80'
    volumes:
      - files:/home/my-app/uploaded_files
    depends_on:
      - mysql
volumes:
  files:
  db:
```  

## Environment variables

* AWS_ACCESS_KEY_ID - AWS user credentials with bucket put-object and get-object access
* AWS_SECRET_ACCESS_KEY
* AWS_BUCKET - S3 Bucket name
* MYSQL_USERNAME
* MYSQL_PASSWORD
* MYSQL_DATABASE
* PREFIX - project name / folder name to put backups on
* CRON_SCHEDULE (optional) - cron schedule for automatic backups, defaults to 3am every day

## What about backup retention?

You can set [lifecycle management rules](http://docs.aws.amazon.com/AmazonS3/latest/dev/object-lifecycle-mgmt.html) on S3 backup that will automatically keep deleted versions of backup for specified number of days.