# Copyright (c) 2023 Schweitzer Engineering Laboratories, Inc.
# SEL Confidential

# Example build command:
# docker build . -t ffdo-docker-dev.artifactory.metro.ad.selinc.com/dev-container:<version>
# GO_DEV_CONTAINER=1.0.2 && docker build . -t devops-docker-prod.artifactory.metro.ad.selinc.com/go-dev-container:${GO_DEV_CONTAINER} && docker push devops-docker-prod.artifactory.metro.ad.selinc.com/go-dev-container:${GO_DEV_CONTAINER}

FROM ubuntu:24.04

# Deletes the default ubuntu user that is using uid 1000.
RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

# Proxy Settings
# ARG PROXY_HTTP="http://wall.ad.selinc.com:8080"
# ARG PROXY_NO='localhost,localaddress,svc.cluster.local,host.docker.internal,kubernetes.docker.internal,.svc.cluster.local,cluster.local,.cluster.local,default.svc,docker.sel.inc,sel.inc,.sel.inc,ad.selinc.com,.ad.selinc.com,metro.ad.selinc.com,.metro.ad.selinc.com,bitbucket.metro.ad.selinc.com,artifactory.metro.ad.selinc.com,*.ad.selinc.com,10.43.0.1,127.0.0.1,127.0.0.0,0.0.0.0,127.0.0.0/8,10.0.0.0/8,10.*.*.*,10.*,172.16.0.0/12,192.168.0.0/16,169.254.169.254'

# ENV HTTP_PROXY=${PROXY_HTTP}
# ENV HTTPS_PROXY=${PROXY_HTTP}
# ENV http_proxy=${PROXY_HTTP}
# ENV https_proxy=${PROXY_HTTP}
# ENV no_proxy=${PROXY_NO}
# ENV NO_PROXY=${PROXY_NO}

# Locale not set in dev container which is required by ansible. Fix that issue by exporting the locale
ENV LC_ALL="C.UTF-8"

# nvm environment variables
#ENV NVM_DIR="/usr/local/nvm"
#ENV NODE_VERSION="20.8.0"

# Environment variables for Go
ENV GOPATH="/go"
#ENV GOPROXY="https://artifactory.metro.ad.selinc.com/artifactory/api/go/sel-go"
#ENV GOPRIVATE="bitbucket.metro.ad.selinc.com/*"
ENV PATH="${PATH}:/usr/local/go/bin:/go/bin"

# Tell apt-get to not ask questions otherwise fail.
ARG DEBIAN_FRONTEND="noninteractive"

# Node Version that NVM will install.
#ARG NVM_VERSION="0.39.5"

# Go and Tools
ARG GOLANG_VERSION="1.21.2"
ARG GO_DELVE_DLV_VERSION="1.21.1"
ARG GO_FUMPT_VERSION="0.5.0"
ARG GOLANG_CI_LINT_VERSION="1.54.2"

# Install apt packages
RUN apt-get update && apt-get upgrade -y && \ 
    apt-get install -y \
    curl \
    git \
    unzip \
    jq \
    wget \
    ssh \
    gnupg \
    ca-certificates \
    software-properties-common && \
    apt-get -y autoremove && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install NVM and Node
#RUN mkdir ${NVM_DIR} && \
#    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash

# Install python 3.8
# RUN add-apt-repository ppa:deadsnakes/ppa && \
#     apt-get update && \
#     apt-get install -y \
#     python3.8 \
#     python3-pip && \
#     apt-get -y autoremove && \
#     apt-get -qq clean && \
#     rm -rf /var/lib/apt/lists/*

# Install ansible and pywinrm and set python index
# RUN pip config --global set global.index "https://artifactory.metro.ad.selinc.com/artifactory/api/pypi/sel-pypi/simple" && \
#     pip config --global set global.index-url "https://artifactory.metro.ad.selinc.com/artifactory/api/pypi/sel-pypi/simple" && \
#     pip install ansible && \
#     pip install pywinrm && \
#     pip install keeper-secrets-manager-cli

# Install ZScaler SSL Certificate
# Note: We changed the file name of zscaler-root-ca.crt to zscaler.crt because we use this file in
# k3d as well and Docker is confused by the dashes in the file name.
#ADD http://gauss.ad.selinc.com/CertData/zscaler-root-ca.crt /usr/local/share/ca-certificates/zscaler.crt
#RUN chmod 644 /usr/local/share/ca-certificates/zscaler.crt && update-ca-certificates

# Install go
RUN curl --connect-timeout 15 --retry 5 --retry-delay 5 -O https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz

# Install golangci-lint.
# hadolint ignore=SC2046
RUN curl --connect-timeout 15 --retry 5 --retry-delay 5 -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
    sh -s -- -b $(go env GOPATH)/bin v${GOLANG_CI_LINT_VERSION}
RUN go install github.com/go-delve/delve/cmd/dlv@v${GO_DELVE_DLV_VERSION}
RUN go install mvdan.cc/gofumpt@v${GO_FUMPT_VERSION}
RUN go install golang.org/x/tools/gopls@latest

ARG USERNAME="vscode"

WORKDIR /tmp
COPY setup-user.sh .

# Make it so we can use sudo.
RUN apt-get update && apt-get install --no-install-recommends -y \
    sudo && \
    apt-get -y autoremove && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x setup-user.sh && \ 
    ./setup-user.sh "${USERNAME}" "1000" "1000" && \
    rm /tmp/setup-user.sh

# Change ownership of Go packages during build instead of during dev container startup.
RUN echo "golang:x:999:vscode" >> /etc/group
RUN chgrp -R 999 /go && chmod -R g+rwx /go

# Create docker-init.sh to spin up Socat to give VS Code user Docker socket permissions.
# RUN printf '#!/bin/sh\n\
#     rm /var/run/docker.sock > /dev/null 2>&1 \n\
#     ((sudo socat UNIX-LISTEN:/var/run/docker.sock,fork,mode=660,user=vscode UNIX-CONNECT:/var/run/docker-host.sock) 2>&1 >> /tmp/vscr-dind-socat.log) & > /dev/null\n\
#     "$@"' >> /usr/local/share/docker-init.sh \
#     && chmod +x /usr/local/share/docker-init.sh

CMD [ "sleep", "infinity" ]