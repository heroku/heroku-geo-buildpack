# These targets are not files
.PHONY: compile test build-heroku-20 build-heroku-22

STACK_VERSION ?= 22
STACK := heroku-$(STACK_VERSION)
BASE_BUILD_IMAGE := heroku/heroku:$(STACK_VERSION)-build
PLATFORM := linux/amd64

compile:
	@echo "Running compile using: STACK_VERSION=$(STACK_VERSION)"
	@echo "To use a different stack, run: 'make compile STACK_VERSION=NN'"
	@echo
	@docker run --rm --platform=$(PLATFORM) -v "$(PWD):/src:ro" -e "STACK=$(STACK)" -w /buildpack "$(BASE_BUILD_IMAGE)" \
		bash -c 'cp -r /src/bin /buildpack && mkdir -p /tmp/{build,cache,env} && bin/compile /tmp/build /tmp/cache /tmp/env'
	@echo

test:
	@echo "Running tests using: STACK_VERSION=$(STACK_VERSION)"
	@echo "To use a different stack, run: 'make test STACK_VERSION=NN'"
	@echo
	@docker run --rm --platform=$(PLATFORM) -v "$(PWD):/buildpack:ro" -e "STACK=$(STACK)" "$(BASE_BUILD_IMAGE)" /buildpack/tests.sh
	@echo

build-heroku-20:
	@echo "Creating build environment (heroku-20)..."
	@echo
	@docker build --pull -f "$(shell pwd)/builds/Dockerfile-heroku-20" -t buildenv-heroku-20 .
	@echo
	@echo "Usage..."
	@echo
	@echo "  $$ export S3_BUCKET='heroku-geo-buildpack' # Optional unless deploying"
	@echo "  $$ export AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar  # Optional unless deploying"
	@echo "  $$ ./builds/gdal/gdal-<version>.sh"
	@echo
	@docker run -e STACK="heroku-20" -e S3_BUCKET -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -it --rm buildenv-heroku-20

build-heroku-22:
	@echo "Creating build environment (heroku-22)..."
	@echo
	@docker build --pull -f "$(shell pwd)/builds/Dockerfile-heroku-22" -t buildenv-heroku-22 .
	@echo
	@echo "Usage..."
	@echo
	@echo "  $$ export S3_BUCKET='heroku-geo-buildpack' # Optional unless deploying"
	@echo "  $$ export AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar  # Optional unless deploying"
	@echo "  $$ ./builds/gdal/gdal-<version>.sh"
	@echo
	@docker run -e STACK="heroku-22" -e S3_BUCKET -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -it --rm buildenv-heroku-22
