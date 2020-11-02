test-heroku-16:
	@echo "Running tests in docker (heroku-16)..."
	@docker run -v "$(shell pwd):/buildpack:ro" --rm -it -e "STACK=heroku-16" heroku/heroku:16-build bash -c '/buildpack/tests.sh'
	@echo ""

test-heroku-18:
	@echo "Running tests in docker (heroku-18)..."
	@docker run -v "$(shell pwd):/buildpack:ro" --rm -it -e "STACK=heroku-18" heroku/heroku:18-build bash -c '/buildpack/tests.sh'
	@echo ""

test-heroku-20:
	@echo "Running tests in docker (heroku-20)..."
	@docker run -v "$(shell pwd):/buildpack:ro" --rm -it -e "STACK=heroku-20" heroku/heroku:20-build bash -c '/buildpack/tests.sh'
	@echo ""

build-heroku-16:
	@echo "Creating build environment (heroku-16)..."
	@echo
	@docker build --pull -f "$(shell pwd)/builds/Dockerfile-heroku-16" -t buildenv-heroku-16 .
	@echo
	@echo "Usage..."
	@echo
	@echo "  $$ export S3_BUCKET='heroku-geo-buildpack' # Optional unless deploying"
	@echo "  $$ export AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar  # Optional unless deploying"
	@echo "  $$ ./builds/gdal/gdal-version"
	@echo
	@docker run -e STACK="heroku-16" -it --rm buildenv-heroku-16

build-heroku-18:
	@echo "Creating build environment (heroku-18)..."
	@echo
	@docker build --pull -f "$(shell pwd)/builds/Dockerfile-heroku-18" -t buildenv-heroku-18 .
	@echo
	@echo "Usage..."
	@echo
	@echo "  $$ export S3_BUCKET='heroku-geo-buildpack' # Optional unless deploying"
	@echo "  $$ export AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar  # Optional unless deploying"
	@echo "  $$ ./builds/gdal/gdal-version"
	@echo
	@docker run -e STACK="heroku-18" -it --rm buildenv-heroku-18

build-heroku-20:
	@echo "Creating build environment (heroku-20)..."
	@echo
	@docker build --pull -f "$(shell pwd)/builds/Dockerfile-heroku-20" -t buildenv-heroku-20 .
	@echo
	@echo "Usage..."
	@echo
	@echo "  $$ export S3_BUCKET='heroku-geo-buildpack' # Optional unless deploying"
	@echo "  $$ export AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar  # Optional unless deploying"
	@echo "  $$ ./builds/gdal/gdal-version"
	@echo
	@docker run -e STACK="heroku-20" -it --rm buildenv-heroku-20
