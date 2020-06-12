#!/bin/bash

# shellcheck source=builds/geos/geos.sh
source "$(dirname "$0")/geos.sh"
deploy_geos "3.7.2"
