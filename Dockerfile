FROM mysql:5.6
# install basic packages
RUN apt-get update && apt-get install -y curl unzip python cron
# install aws cli
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && unzip awscli-bundle.zip && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# copy all scripts
COPY *.sh /

CMD ["./entrypoint.sh"]