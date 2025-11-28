ARG STACK_VERSION="24"
FROM heroku/heroku:${STACK_VERSION}-build

ARG STACK_VERSION
ENV STACK="heroku-${STACK_VERSION}"

# For Heroku-24 and newer, the build image sets a non-root default `USER`.
USER root

RUN apt-get update --error-on=any \
    && apt-get install -y --no-install-recommends \
      libkml-dev \
      libsqlite3-dev \
      sqlite3 \
    && rm -rf /var/lib/apt/lists/*

ADD . /heroku-geo-buildpack

WORKDIR "/heroku-geo-buildpack"
