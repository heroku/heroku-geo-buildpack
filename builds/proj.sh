#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:?"Error: The PROJ version to build must be specified as the first argument."}"

SRC_DIR="$(mktemp -d)"
INSTALL_DIR="$(mktemp -d)"
ARCHIVE_DIR="/tmp/upload/${STACK}/PROJ"

CONCURRENCY="$(nproc)"

echo "Building PROJ ${VERSION} for ${STACK}..."

set -o xtrace

cd "${SRC_DIR}"
curl -sSf --retry 3 --retry-connrefused --connect-timeout 10 --max-time 60 "https://download.osgeo.org/proj/proj-${VERSION}.tar.gz" \
  | tar --gzip --extract --strip-components=1 --directory .

# https://proj.org/en/stable/install.html#compilation-and-installation-from-source-code
mkdir build
cd build
cmake \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
  ..
cmake --build . -j "${CONCURRENCY}"
cmake --build . --target install -j "${CONCURRENCY}"

# Strip binaries to reduce package size.
find "${INSTALL_DIR}" -type f \( -executable -o -name '*.so*' \) -print -exec strip --strip-unneeded '{}' +

mkdir -p "${ARCHIVE_DIR}"
TAR_FILEPATH="${ARCHIVE_DIR}/PROJ-${VERSION}.tar"
tar --create --format=pax --sort=name --file="${TAR_FILEPATH}" --directory="${INSTALL_DIR}" .
gzip --best "${TAR_FILEPATH}"
