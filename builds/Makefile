build-heroku-16:
	@echo "Creating build environment (heroku-16)..."
	@echo
	@docker build --pull -f Dockerfile-heroku-16 -t buildenv-heroku-16 .
	@echo
	@echo "Usage..."
	@echo
	@echo "  $$ export S3_BUCKET='heroku-geo-buildpack' # Optional unless deploying"
	@echo "  $$ export AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar  # Optional unless deploying"
	@echo "  $$ ./gdal '2.3.2'"
	@echo
	@docker run -e STACK="heroku-16" -it --rm buildenv-heroku-16

build-heroku-18:
	@echo "Creating build environment (heroku-18)..."
	@echo
	@docker build --pull -f Dockerfile-heroku-18 -t buildenv-heroku-18 .
	@echo
	@echo "Usage..."
	@echo
	@echo "  $$ export S3_BUCKET='heroku-geo-buildpack' # Optional unless deploying"
	@echo "  $$ export AWS_ACCESS_KEY_ID=foo AWS_SECRET_ACCESS_KEY=bar  # Optional unless deploying"
	@echo "  $$ ./gdal '2.3.2'"
	@echo
	@docker run -e STACK="heroku-18" -it --rm buildenv-heroku-18
