test-heroku-20:
	@echo "Running tests in docker (heroku-20)..."
	@docker run -v "$(shell pwd):/buildpack:ro" --rm -it -e "STACK=heroku-20" heroku/heroku:20-build bash -c '/buildpack/tests.sh'
	@echo ""

test-heroku-22:
	@echo "Running tests in docker (heroku-22)..."
	@docker run -v "$(shell pwd):/buildpack:ro" --rm -it -e "STACK=heroku-20" heroku/heroku:22-build bash -c '/buildpack/tests.sh'
	@echo ""

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
