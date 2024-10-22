#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# cSpell:ignore ncdu, epel, buildx, socat, devel, selinc, btop, iputils, nmap

# Install system packages
main() {
  source "/usr/bin/lib/sh/log.sh"
  log "10-install-system-packages.sh" "blue"

  log "Adding install_weak_deps=False to /etc/dnf/dnf.conf" "green"
  echo "install_weak_deps=False" >>/etc/dnf/dnf.conf

  log "Installing epel release" "green"
  dnf install -y epel-release && dnf clean all

  log "Installing dnf plugins core" "green"
  dnf install -y dnf-plugins-core

  log "Running /usr/bin/crb enable" "green"
  /usr/bin/crb enable

  log "Adding docker ce repo" "green"
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  log "Running dnf upgrade" "green"
  dnf upgrade -y

  log "Installing bash completion" "green"
  dnf install -y bash-completion

  log "Installing bind-utils" "green"
  dnf install -y bind-utils

  log "Installing btop" "green"
  dnf install -y btop

  dnf install -y sudo

  log "Installing ca-certificates" "green"
  dnf install -y ca-certificates

  log "Installin docker-ce-cli" "green"
  dnf install -y docker-ce-cli

  log "Installing docker-buildx-plugin" "green"
  dnf install -y docker-buildx-plugin

  log "Installing expect" "green"
  dnf install -y expect

  log "install genisoimage" "green"
  dnf install -y genisoimage

  log "Installing git" "green"
  dnf install -y git

  log "Installing graphviz" "green"
  dnf install -y graphviz

  log "Installing gnupg2" "green"
  dnf install -y gnupg2

  log "Installing iputils" "green"
  dnf install -y iputils

  log "Installing jq" "green"
  dnf install -y jq

  log "Installing ncdu" "green"
  dnf install -y ncdu

  log "Installing net-snmp-utils" "green"
  dnf install -y net-snmp-utils

  log "Installing nmap" "green"
  dnf install -y nmap

  log "Installing sshpass" "green"
  dnf install -y sshpass

  log "Installing socat" "green"
  dnf install -y socat

  log "Install traceroute" "green"
  dnf install -y traceroute

  log "Installing util-linux-user" "green"
  dnf install -y util-linux-user

  log "Installing wget" "green"
  dnf install -y wget

  log "Installing xz zip unzip" "green"
  dnf install -y xz zip unzip

  log "Running dnf autoremove" "green"
  dnf autoremove -y

  log "Running dnf clean all" "green"
  dnf clean all

  log "Deleting files from /tmp" "green"
  rm -rf /tmp/*
}

# Run main
if ! (return 0 2>/dev/null); then
  (main "$@")
fi