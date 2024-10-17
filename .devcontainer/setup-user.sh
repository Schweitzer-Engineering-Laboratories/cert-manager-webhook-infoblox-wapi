#!/bin/bash

# Copyright (c) 2023 Schweitzer Engineering Laboratories, Inc.
# SEL Confidential
set -e

USERNAME=${1:-""}
USER_UID=${2:-""}
USER_GID=${3:-""}

if [ "$(id -u)" -ne 0 ]; then
  echo -e "Script must be run as root."
  exit 1
fi

# Create or update a non-root user to match UID/GID.
if id -u "$USERNAME" > /dev/null 2>&1; then
  # User exists, update if needed.
  if [ "$USER_GID" != "automatic" ] && [ "$USER_GID" != "$(id -G "$USERNAME")" ]; then
    groupmod --gid "$USER_GID" "$USERNAME"
    usermod --gid "$USER_GID" "$USERNAME"
  fi
  if [ "$USER_UID" != "automatic" ] && [ "$USER_UID" != "$(id -u "$USERNAME")" ]; then
    usermod --uid "$USER_UID" "$USERNAME"
  fi
else
  # Create the user.
  if [ "$USER_GID" = "automatic" ]; then
    groupadd "$USERNAME"
  else
    groupadd --gid "$USER_GID" "$USERNAME"
  fi
  if [ "$USER_UID" = "automatic" ]; then
    useradd -s /bin/bash --gid "$USERNAME" -m "$USERNAME"
  else
    useradd -s /bin/bash --uid "$USER_UID" --gid "$USERNAME" -m "$USERNAME"
  fi
fi

# Add add sudo support for non-root user.
if [ "$USERNAME" != "root" ] && [ "$EXISTING_NON_ROOT_USER" != "$USERNAME" ]; then
  # shellcheck disable=SC2086
  # Bash doesn't like double quoting the echo input here.
  mkdir -p /etc/sudoers.d
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > "/etc/sudoers.d/$USERNAME"
  chmod 0440 /etc/sudoers.d/"$USERNAME"
  EXISTING_NON_ROOT_USER="$USERNAME"
fi