#!/bin/bash

set -eo pipefail

# shellcheck source=builds/proj/proj.sh
source "$(dirname "$0")/proj.sh"
deploy_proj "5.2.0"
