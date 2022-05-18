#!/bin/bash

deploy_gdal() {
    VERSION=$1
    WORKSPACE=$2
    OUTPUT=$3

    # build and package gdal.sh
    pushd "$WORKSPACE" || exit 1

    curl "https://download.osgeo.org/gdal/$VERSION/gdal-$VERSION.tar.gz" -sSf -o - | tar zxf -
    pushd "gdal-$VERSION" || exit 1

    # TODO: Once GDAL 3.5.0 is the oldest supported version, remove the `--without-jasper`
    # usage, since it no longer does anything after https://github.com/OSGeo/gdal/pull/5269
    ./configure --prefix="$OUTPUT" --enable-static=no --without-jasper --with-libkml="$OUTPUT" --with-hide-internal-symbols
    make
    make install

    pushd "$OUTPUT" || exit 1
    for i in lib/*; do strip -s $i 2>/dev/null || /bin/true; done
    for i in bin/*; do strip -s $i 2>/dev/null || /bin/true; done
    tar -czf "GDAL-$VERSION.tar.gz" ./*

    if [[ $S3_BUCKET && $AWS_ACCESS_KEY_ID && $AWS_SECRET_ACCESS_KEY ]]; then
        aws s3 cp --acl public-read "GDAL-$VERSION.tar.gz" "s3://$S3_BUCKET/$STACK/GDAL/"
    fi
}
