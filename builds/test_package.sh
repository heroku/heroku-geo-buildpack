#!/usr/bin/env bash

set -euo pipefail

ARCHIVE_FILEPATH="${1:?"Error: The filepath of the archive must be specified as the first argument."}"

INSTALL_DIR=$(mktemp -d)
export LD_LIBRARY_PATH="${INSTALL_DIR}/lib/"

tar --gzip --extract --verbose --file "${ARCHIVE_FILEPATH}" --directory "${INSTALL_DIR}"

# Checks that no libraries are missing from the run image (since it has fewer packages installed).
LDD_OUTPUT=$(find "${INSTALL_DIR}" -type f \( -executable -o -name '*.so*' \) ! \( -name 'gdal-config' -o -name 'geos-config' -o -name '*.la' \) -exec ldd '{}' +)
if grep 'not found' <<<"${LDD_OUTPUT}" | sort --unique; then
  echo "The above dynamically linked libraries were not found!"
  exit 1
fi
