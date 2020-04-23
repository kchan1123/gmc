#!/bin/sh

set -e

if [ ! -f "build/env.sh" ]; then
    echo "$0 must be run from the root of the repository."
    exit 2
fi

# Create fake Go workspace if it doesn't exist yet.
workspace="$PWD/build/_workspace"
root="$PWD"
ceodir="$workspace/src/github.com/gmc"
if [ ! -L "$ceodir/gmcc" ]; then
    mkdir -p "$ceodir"
    cd "$ceodir"
    ln -s ../../../../../. gmcc
    cd "$root"
fi

# Set up the environment to use the workspace.
GOPATH="$workspace"
export GOPATH

# Run the command inside the workspace.
cd "$ceodir/gmcc"
PWD="$ceodir/gmcc"

# Launch the arguments with the configured environment.
exec "$@"
