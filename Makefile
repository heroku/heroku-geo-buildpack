# These targets are not files
.PHONY: compile test buildenv

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

buildenv:
	@echo "Creating build environment using: STACK_VERSION=$(STACK_VERSION)"
	@echo "To use a different stack, run: 'make buildenv STACK_VERSION=NN'"
	@echo
	@docker build --pull --platform=$(PLATFORM) --build-arg="STACK_VERSION=$(STACK_VERSION)" -t "geo-buildenv-$(STACK_VERSION)" ./builds/
	@echo
	@echo "Usage..."
	@echo
	@echo '  $$ docker run --rm -it -v "$${PWD}/upload:/tmp/upload" geo-buildenv-$(STACK_VERSION) ./proj.sh X.Y.Z'
	@echo '  $$ docker run --rm -it -v "$${PWD}/upload:/tmp/upload" geo-buildenv-$(STACK_VERSION) ./geos.sh X.Y.Z'
	@echo '  $$ docker run --rm -it -v "$${PWD}/upload:/tmp/upload" geo-buildenv-$(STACK_VERSION) ./gdal.sh X.Y.Z'
	@echo
