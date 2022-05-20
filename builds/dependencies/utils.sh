#!/bin/bash

vendor_dependency() {
    DEP=$1
    VERSION=$2
    VENDOR_DIR=$3

    echo "-----> Installing $DEP-$VERSION"
    DEP_URL="https://heroku-buildpack-geo.s3.amazonaws.com/${STACK}/${DEP}/${DEP}-${VERSION}.tar.gz"

    mkdir -p "$VENDOR_DIR"
    if ! curl "${DEP_URL}" -sSf | tar zxv -C "$VENDOR_DIR"; then
      echo " !     Requested $DEP Version ($VERSION) is not available for this stack ($STACK)."
      echo " !     Aborting."
      exit 1
    fi
}