#!/bin/sh
set -e

echo "Activating feature 'semgrep-cli'"
echo "The provided Semgrep version is : ${SEMGREP_VERSION}"


# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

set -e

ensure_curl () {
    if ! type curl >/dev/null 2>&1; then
        apt-get update -y && apt-get -y install --no-install-recommends curl ca-certificates
    fi 
}


ensure_featmake () {
    if ! type featmake > /dev/null 2>&1; then
        temp_dir=/tmp/featmake-download
        mkdir -p $temp_dir

        curl -sSL -o $temp_dir/featmake https://github.com/devcontainers-contrib/cli/releases/download/v0.0.19/featmake 
        curl -sSL -o $temp_dir/checksums.txt https://github.com/devcontainers-contrib/cli/releases/download/v0.0.19/checksums.txt

        (cd $temp_dir ; sha256sum --check --strict $temp_dir/checksums.txt)

        chmod a+x $temp_dir/featmake
        mv -f $temp_dir/featmake /usr/local/bin/featmake

        rm -rf $temp_dir
    fi
}

ensure_curl

ensure_featmake

# installing ghcr.io/devcontainers-contrib/features/pipx-package:1.1.3
featmake "ghcr.io/devcontainers-contrib/features/pipx-package:1.1.3" -PACKAGE "semgrep" -VERSION "$SEMGREP_VERSION" -INJECTIONS "semgrep" 
