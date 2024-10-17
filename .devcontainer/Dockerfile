# syntax=docker/dockerfile:1
# cspell:ignore FUMPT mvdan gofumpt gopls

# Example build command:
# GO_DEV_CONTAINER=dev-container-1.0.0 && docker build . -t ghcr.io/schweitzer-engineering-laboratories/cert-manager-webhook-infoblox-wapi:${GO_DEV_CONTAINER} && docker push ghcr.io/schweitzer-engineering-laboratories/cert-manager-webhook-infoblox-wapi:${GO_DEV_CONTAINER} && docker tag ghcr.io/schweitzer-engineering-laboratories/cert-manager-webhook-infoblox-wapi:${GO_DEV_CONTAINER} ghcr.io/schweitzer-engineering-laboratories/cert-manager-webhook-infoblox-wapi:dev-container-latest && docker push ghcr.io/schweitzer-engineering-laboratories/cert-manager-webhook-infoblox-wapi:dev-container-latest

FROM ubuntu:24.04

# Deletes the default ubuntu user that is using uid 1000.
RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

LABEL org.opencontainers.image.source https://github.com/schweitzer-engineering-laboratories/cert-manager-webhook-infoblox-wapi

# Locale not set in dev container which is required by ansible. Fix that issue by exporting the locale
ENV LC_ALL="C.UTF-8"

# Environment variables for Go
ENV GOPATH="/go"
ENV PATH="${PATH}:/usr/local/go/bin:/go/bin"

# Tell apt-get to not ask questions otherwise fail.
ARG DEBIAN_FRONTEND="noninteractive"

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
  wget \
  ssh \
  gnupg \
  ca-certificates \
  software-properties-common && \
  apt-get -y autoremove && \
  apt-get -qq clean && \
  rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install go
RUN curl --connect-timeout 15 --retry 5 --retry-delay 5 -O https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
  tar -C /usr/local -xf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
  rm go${GOLANG_VERSION}.linux-amd64.tar.gz

# Install golangci-lint.
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

CMD [ "sleep", "infinity" ]