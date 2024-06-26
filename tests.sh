#!/usr/bin/env bash

set -euo pipefail

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
  assertContains "$stdout" "-----> GDAL_VERSION is not set. Using the buildpack default: 3.9.0"
  assertContains "$stdout" "-----> GEOS_VERSION is not set. Using the buildpack default: 3.12.1"
  assertContains "$stdout" "-----> PROJ_VERSION is not set. Using the buildpack default: 9.4.0"
  assertContains "$stdout" "-----> Installing GDAL-3.9.0"
  assertContains "$stdout" "-----> Installing GEOS-3.12.1"
  assertContains "$stdout" "-----> Installing PROJ-9.4.0"

  # Cached build
  stdout=$(compile)
  assertEquals "0" "$?"
  assertContains "$stdout" "-----> GDAL_VERSION is not set. Using the same version as the last build: 3.9.0"
  assertContains "$stdout" "-----> GEOS_VERSION is not set. Using the same version as the last build: 3.12.1"
  assertContains "$stdout" "-----> PROJ_VERSION is not set. Using the same version as the last build: 9.4.0"
  assertContains "$stdout" "-----> Installing GDAL-3.9.0"
  assertContains "$stdout" "-----> Installing GEOS-3.12.1"
  assertContains "$stdout" "-----> Installing PROJ-9.4.0"
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

testSpecifiedVersionInstall() {
  # The versions here should ideally not match the default versions,
  # so that we're testing that it really overrides the defaults.
  setEnvVar "GDAL_VERSION" "3.8.5"
  setEnvVar "GEOS_VERSION" "3.11.3"
  setEnvVar "PROJ_VERSION" "9.4.0"

  stdout=$(compile)
  assertEquals "0" "$?"
  assertContains "$stdout" "-----> Using GDAL version specified by GDAL_VERSION: 3.8.5"
  assertContains "$stdout" "-----> Using GEOS version specified by GEOS_VERSION: 3.11.3"
  assertContains "$stdout" "-----> Using PROJ version specified by PROJ_VERSION: 9.4.0"
  assertContains "$stdout" "-----> Installing GDAL-3.8.5"
  assertContains "$stdout" "-----> Installing GEOS-3.11.3"
  assertContains "$stdout" "-----> Installing PROJ-9.4.0"

  # Cached build
  stdout=$(compile)
  assertEquals "0" "$?"
  assertContains "$stdout" "-----> Using GDAL version specified by GDAL_VERSION: 3.8.5"
  assertContains "$stdout" "-----> Using GEOS version specified by GEOS_VERSION: 3.11.3"
  assertContains "$stdout" "-----> Using PROJ version specified by PROJ_VERSION: 9.4.0"
  assertContains "$stdout" "-----> Installing GDAL-3.8.5"
  assertContains "$stdout" "-----> Installing GEOS-3.11.3"
  assertContains "$stdout" "-----> Installing PROJ-9.4.0"
}

testUnavailableVersionInstall() {
  setEnvVar "GDAL_VERSION" "9.9.9"

  output=$(compile 2>&1)
  assertEquals "1" "$?"
  assertContains "$output" "Error: GDAL version '9.9.9' is not available for this stack ($STACK)."
  assertContains "$output" "Try requesting a different version using the env var 'GDAL_VERSION'"
}

command -v shunit2 || {
  curl -sSfL --retry 3 --retry-connrefused --connect-timeout 10 -o /usr/local/bin/shunit2 https://raw.githubusercontent.com/kward/shunit2/master/shunit2
  chmod +x /usr/local/bin/shunit2
}
# shellcheck disable=SC1091
source shunit2
