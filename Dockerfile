FROM google/cloud-sdk:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    curl \
    unzip \
    jq

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf ./awscliv2.zip \
    && rm -rf ./aws

RUN mkdir -p /root/.aws
COPY aws_config /root/.aws/config

COPY aws_auth.sh /usr/local/sbin/aws_auth.sh
RUN chmod +x /usr/local/sbin/aws_auth.sh