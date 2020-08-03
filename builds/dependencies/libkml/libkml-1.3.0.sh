#!/bin/bash

# We need cmake to build libkml
echo "-----> Installing cmake"
apt-get update -qq
apt-get install -q -y cmake

# workspace directory
workspace="$(mktemp -d)"

# output directory
output="$(mktemp -d)"

# build and package libkml
pushd "$workspace" || exit 1

curl -sL https://github.com/libkml/libkml/tarball/1.3.0 -s -o - | tar zxf -
pushd libkml-libkml-0da164d || exit 1
cmake -DCMAKE_INSTALL_PREFIX="$output" --enable-static=no
make
make install

pushd "$output" || exit 1
tar -czf libkml-1.3.0.tar.gz ./*

if [[ $S3_BUCKET && $AWS_ACCESS_KEY_ID && $AWS_SECRET_ACCESS_KEY ]]; then
    aws s3 cp --acl public-read libkml-1.3.0.tar.gz "s3://$S3_BUCKET/$STACK/libkml/"
fi
