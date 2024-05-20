#!/usr/bin/env bash

vendor_dependency() {
  local DEP="${1}"
  local VERSION="${2}"
  local VENDOR_DIR="${3}"
  local DEP_URL="https://heroku-buildpack-geo.s3.us-east-1.amazonaws.com/${STACK}/${DEP}/${DEP}-${VERSION}.tar.gz"

  if ! curl -sSf --retry 3 --retry-connrefused --connect-timeout 10 --max-time 60 "${DEP_URL}" | tar --gzip --extract --directory "${VENDOR_DIR}"; then
    echo "Error: Dependency ${DEP} ${VERSION} for ${STACK} not found on S3. Make sure it is built first." >&2
    exit 1
  fi
}
