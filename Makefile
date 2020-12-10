default: test

bootstrap:
	./scripts/bootstrap_cloud_build.sh

deploy:
	./scripts/deploy.sh

cleanup:
	./scripts/cleanup.sh

perform-load:
	./scripts/perform-load.sh

init:
	pipenv --venv || pipenv install -d

test: init
	find . -name '*pyc' -delete
	find . -name '__pycache__' -delete
	pipenv run flake8 .
	pipenv run python -m pytest . --cov --cov-report term-missing

run: init
	pipenv run python  productlist/app.py