#!/bin/bash

deploy_geos() {
    VERSION=$1

    # workspace directory
    workspace="$(mktemp -d)"

    # output directory
    output="$(mktemp -d)"

    # build and package geos.sh
    pushd "$workspace" || exit 1
    curl "http://download.osgeo.org/geos/geos-$VERSION.tar.bz2" -s -o - | tar xjf -
    pushd "geos-$VERSION" || exit 1
    ./configure --prefix="$output" --enable-static=no
    make
    make install

    pushd "$output" || exit 1
    tar -czf "GEOS-$VERSION.tar.gz" ./*

    if [[ $S3_BUCKET && $AWS_ACCESS_KEY_ID && $AWS_SECRET_ACCESS_KEY ]]; then
        aws s3 cp --acl public-read "GEOS-$VERSION.tar.gz" "s3://$S3_BUCKET/$STACK/GEOS/"
    fi
}
