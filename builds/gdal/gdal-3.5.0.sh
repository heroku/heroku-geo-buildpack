#!/bin/bash

set -eo pipefail

# shellcheck disable=SC2164
CURRENT_DIR="$(cd "$(dirname "$0")"; pwd)"
ROOT_DIR=$(dirname "$CURRENT_DIR")

# shellcheck source=builds/dependencies/utils.sh
source "$ROOT_DIR/dependencies/utils.sh"

# shellcheck source=builds/gdal/gdal.sh
source "$(dirname "$0")/gdal.sh"

WORKSPACE="$(mktemp -d)"
OUTPUT="$(mktemp -d)"

# Ensure we can find any dependencies
export CPATH="$OUTPUT/include:$CPATH"
export LIBRARY_PATH="$OUTPUT/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$OUTPUT/lib:$LD_LIBRARY_PATH"

# We want to include google's libkml in our gdal.sh build
vendor_dependency "libkml" "1.3.0" "$OUTPUT"

# GDAL now requires PROJ at build time
vendor_dependency "PROJ" "8.2.1" "$OUTPUT"

deploy_gdal "3.5.0" "$WORKSPACE" "$OUTPUT"
