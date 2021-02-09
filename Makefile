.PHONY: app docs

help:
	@echo "Commands:"
	@echo "install         : installs requirements."
	@echo "install-dev     : installs development requirements."
	@echo "install-test    : installs test requirements."
	@echo "test            : runs unit and e2e tests."
	@echo "style           : runs style formatting."
	@echo "clean           : cleans all unecessary files."
	@echo "pypi            : package and distribute to PyPI."
	@echo "checks          : runs all checks (test, style and clean)."
	@echo "docs            : serve generated documentation."

install:
	python -m pip install -e .

install-dev:
	python -m pip install -e ".[dev]"
	pre-commit install

install-test:
	python -m pip install -e ".[test]"

app:
	uvicorn app.api:app --host 0.0.0.0 --port 5000 --reload --reload-dir tagifai --reload-dir app

app-prod:
	gunicorn -c config/gunicorn.py -k uvicorn.workers.UvicornWorker app.api:app

test:
	pytest --cov tagifai --cov-report html --disable-pytest-warnings

style:
	black .
	flake8
	isort .

clean:
	tagifai clean-experiments --experiments-to-keep "best"
	find . -type f -name "*.DS_Store" -ls -delete
	find . | grep -E "(__pycache__|\.pyc|\.pyo)" | xargs rm -rf
	find . | grep -E ".pytest_cache" | xargs rm -rf
	find . | grep -E ".ipynb_checkpoints" | xargs rm -rf
	rm -f .coverage

pypi:
	python setup.py sdist
	python setup.py bdist_wheel --universal
	twine upload dist/*

docs:
	python -m mkdocs serve
