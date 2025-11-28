#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:?"Error: The GEOS version to build must be specified as the first argument."}"

SRC_DIR="$(mktemp -d)"
INSTALL_DIR="$(mktemp -d)"
ARCHIVE_DIR="/tmp/upload/${STACK}/GEOS"

CONCURRENCY="$(nproc)"

echo "Building GEOS ${VERSION} for ${STACK}..."

set -o xtrace

cd "${SRC_DIR}"
curl -sSf --retry 3 --retry-connrefused --connect-timeout 10 --max-time 60 "https://download.osgeo.org/geos/geos-${VERSION}.tar.bz2" \
  | tar --bzip2 --extract --strip-components=1 --directory .

# https://libgeos.org/usage/download/#build-from-source
mkdir build
cd build
cmake \
  -DBUILD_DOCUMENTATION=OFF \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
  ..
make -j "${CONCURRENCY}"
make install -j "${CONCURRENCY}"

# Strip binaries to reduce package size. Files that are executable but not binaries (eg scripts)
# have to be explicitly skipped otherwise `strip` will give 'file format not recognized' errors.
find "${INSTALL_DIR}" -type f \( -executable -o -name '*.so*' \) ! -name 'geos-config' -print -exec strip --strip-unneeded '{}' +

mkdir -p "${ARCHIVE_DIR}"
TAR_FILEPATH="${ARCHIVE_DIR}/GEOS-${VERSION}.tar"
tar --create --format=pax --sort=name --file="${TAR_FILEPATH}" --directory="${INSTALL_DIR}" .
gzip --best "${TAR_FILEPATH}"
