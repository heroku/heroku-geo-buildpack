#!/usr/bin/env bash

testDefaultVersionInstall() {
    compile
    assertCapturedSuccess
    assertCaptured "-----> Installing GDAL-2.4.0"
    assertCaptured "-----> Installing GEOS-3.7.2"
    assertCaptured "-----> Installing PROJ-5.2.0"
}

testAvailableVersionInstall() {
    setEnvVar "GDAL_VERSION" "2.4.2"

    compile
    assertCapturedSuccess
    assertCaptured "-----> Installing GDAL-2.4.2"
}

testUnavailableVersionInstall() {
    setEnvVar "GDAL_VERSION" "9.9.9"
    
    compile
    assertCaptured "Requested GDAL Version (9.9.9) is not available for this stack ($STACK)."
}

setEnvVar () {
    echo "$2" >> "$ENV_DIR/$1"
}

pushd $(dirname 0) >/dev/null
popd >/dev/null

source $(pwd)/test/utils
source $(pwd)/test/shunit2