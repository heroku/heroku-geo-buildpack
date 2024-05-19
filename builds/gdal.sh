#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=builds/utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION="${1:?"Error: The GDAL version to build must be specified as the first argument."}"

SRC_DIR="$(mktemp -d)"
INSTALL_DIR="$(mktemp -d)"
ARCHIVE_DIR="/tmp/upload/${STACK}/GDAL"

CONCURRENCY="$(nproc)"

echo "Building GDAL ${VERSION} for ${STACK}..."

set -o xtrace

# GDAL 3.0.0+ requires PROJ at build time.
vendor_dependency "PROJ" "9.4.0" "${INSTALL_DIR}"

# The optional GEOS features require that GEOS be available at build time.
vendor_dependency "GEOS" "3.12.1" "${INSTALL_DIR}"

# The optional KML features require that libkml be installed. The libkml headers and libs were
# installed in the build environment for this script using APT, but the libs won't be present
# in the run image, so we have to vendor them (and some transitive deps) in the package.
# We don't build libkml from source since its last official release is from 2015 and broken:
# https://github.com/heroku/heroku-geo-buildpack/issues/51
cp /lib/x86_64-linux-gnu/{libkml,libminizip,liburiparser}* "${INSTALL_DIR}/lib"

# Ensure vendored dependencies can be found.
export CPATH="${INSTALL_DIR}/include"
export LIBRARY_PATH="${INSTALL_DIR}/lib"
export LD_LIBRARY_PATH="${INSTALL_DIR}/lib"

cd "${SRC_DIR}"
curl -sSf --retry 3 --retry-connrefused --connect-timeout 10 --max-time 60 "https://download.osgeo.org/gdal/${VERSION}/gdal-${VERSION}.tar.gz" \
  | tar --gzip --extract --strip-components=1 --directory .

# https://gdal.org/development/building_from_source.html
mkdir build
cd build
cmake \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
  ..
cmake --build . -j "${CONCURRENCY}"
cmake --build . --target install -j "${CONCURRENCY}"

# Strip binaries to reduce package size. Files that are executable but not binaries (eg scripts)
# have to be explicitly skipped otherwise `strip` will give 'file format not recognized' errors.
find "${INSTALL_DIR}" -type f \( -executable -o -name '*.so*' \) ! \( -name 'gdal-config' -o -name 'geos-config' -o -name '*.la' \) -print -exec strip --strip-unneeded '{}' +

mkdir -p "${ARCHIVE_DIR}"
TAR_FILEPATH="${ARCHIVE_DIR}/GDAL-${VERSION}.tar"
tar --create --format=pax --sort=name --file="${TAR_FILEPATH}" --directory="${INSTALL_DIR}" .
gzip --best "${TAR_FILEPATH}"
