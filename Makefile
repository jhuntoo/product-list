export FLASK_APP=productlist:create_app()

default: test

bootstrap:
	./scripts/bootstrap_cloud_build.sh

deploy:
	./scripts/deploy.sh

init:
	pipenv --venv || pipenv install -d

test: init
	find . -name '*pyc' -delete
	find . -name '__pycache__' -delete
	pipenv run flake8 .
	LOG_LEVEL=INFO CONTRAST__ENABLE=false pipenv run python -m pytest . --cov --cov-report term-missing

run: init
	FLASK_DEBUG=True pipenv run flask run