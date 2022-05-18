#!/bin/bash

deploy_proj() {
    VERSION=$1

    # workspace directory
    workspace="$(mktemp -d)"

    # output directory
    output="$(mktemp -d)"

    # build and package proj.sh
    pushd "$workspace" || exit 1
    curl "https://download.osgeo.org/proj/proj-$VERSION.tar.gz" -s -o - | tar zxf -
    pushd "proj-$VERSION" || exit 1
    ./configure --prefix="$output" --enable-static=no
    make
    make install

    pushd "$output" || exit 1
    for i in lib/*; do strip -s $i 2>/dev/null || /bin/true; done
    for i in bin/*; do strip -s $i 2>/dev/null || /bin/true; done
    tar -czf "PROJ-$VERSION.tar.gz" ./*

    if [[ $S3_BUCKET && $AWS_ACCESS_KEY_ID && $AWS_SECRET_ACCESS_KEY ]]; then
        aws s3 cp --acl public-read "PROJ-$VERSION.tar.gz" "s3://$S3_BUCKET/$STACK/PROJ/"
    fi
}
