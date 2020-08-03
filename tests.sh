#!/usr/bin/env bash

BASE_DIR=$(dirname "$0")

oneTimeSetUp () {
  BUILDPACK_DIR=$(mktemp -d "$SHUNIT_TMPDIR/buildpack.XXXX")
  cp -r "$BASE_DIR/bin" "$BUILDPACK_DIR/bin"
}

setUp () {
  BUILD_DIR=$(mktemp -d "${SHUNIT_TMPDIR}/build.XXXX")
  CACHE_DIR=$(mktemp -d "${SHUNIT_TMPDIR}/cache.XXXX")
  ENV_DIR=$(mktemp -d "${SHUNIT_TMPDIR}/env.XXXX")
}

tearDown () {
  rm -rf "$BUILD_DIR" "$CACHE_DIR" "$ENV_DIR"
}

detect()
{
  "${BUILDPACK_DIR}/bin/detect" "$BUILD_DIR"
}

compile()
{
  "$BUILDPACK_DIR/bin/compile" "$BUILD_DIR" "$CACHE_DIR" "$ENV_DIR"
}

release()
{
  "$BUILDPACK_DIR/bin/release" "$BUILD_DIR"
}

setEnvVar () {
  echo "$2" >> "$ENV_DIR/$1"
}

testDefaultVersionInstall() {
  stdout=$(compile)
  assertEquals "0" "$?"
  assertContains "$stdout" "-----> Installing GDAL-2.4.0"
  assertContains "$stdout" "-----> Installing GEOS-3.7.2"
  assertContains "$stdout" "-----> Installing PROJ-5.2.0"
}

testBuildpackEnv() {
  stdout=$(compile)
  PROFILE=$(<"$BUILDPACK_DIR/export")

  assertContains "$PROFILE" "PATH=\"$BUILD_DIR/.heroku-geo-buildpack/vendor/bin:\$PATH\""
  assertContains "$PROFILE" "LIBRARY_PATH=\"$BUILD_DIR/.heroku-geo-buildpack/vendor/lib:\$LIBRARY_PATH\""
  assertContains "$PROFILE" "LD_LIBRARY_PATH=\"$BUILD_DIR/.heroku-geo-buildpack/vendor/lib:\$LD_LIBRARY_PATH\""
  assertContains "$PROFILE" "CPLUS_INCLUDE_PATH=\"$BUILD_DIR/.heroku-geo-buildpack/vendor/include:\$CPLUS_INCLUDE_PATH\""
  assertContains "$PROFILE" "C_INCLUDE_PATH=\"$BUILD_DIR/.heroku-geo-buildpack/vendor/include:\$C_INCLUDE_PATH\""
}

testAvailableVersionInstall() {
  setEnvVar "GDAL_VERSION" "2.4.2"

  stdout=$(compile)
  assertEquals "0" "$?"
  assertContains "$stdout" "-----> Installing GDAL-2.4.2"
}

testUnavailableVersionInstall() {
  setEnvVar "GDAL_VERSION" "9.9.9"

  stdout=$(compile)
  assertEquals "1" "$?"
  assertContains "$stdout" "Requested GDAL Version (9.9.9) is not available for this stack ($STACK)."
}


command -v shunit2 || {
  curl -sLo /usr/local/bin/shunit2 https://raw.githubusercontent.com/kward/shunit2/master/shunit2
  chmod +x /usr/local/bin/shunit2
}
# shellcheck disable=SC1091
source shunit2
