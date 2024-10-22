#!/bin/bash
#
# This script will start the dev container outside of VSCode and can be used on non VSCode go projects.

set -euo pipefail
IFS=$'\n\t'

main() {
  # Name of the container
  local container_name="ghcr.io/schweitzer-engineering-laboratories/go-dev-container:latest"

  # User being created in the container
  local container_user="vscode"

  docker run --mount type=bind,source="$(pwd)",target=/workspaces/working \
    -w /workspaces/working -it --rm -u "${container_user}" \
    "${container_name}" zsh

}

if ! (return 0 2>/dev/null); then
  (main "$@")
fi
