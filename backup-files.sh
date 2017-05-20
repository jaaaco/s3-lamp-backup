#!/usr/bin/env bash
set -e
tar zcfv files.tar.gz /files/
aws s3api put-object --bucket $AWS_BUCKET --key $PREFIX/files.tar.gz --body files.tar.gz
rm files.tar.gz