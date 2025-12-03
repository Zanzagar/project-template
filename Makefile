PY=python
PIP=pip

.PHONY: install dev fmt lint test build

install:
	$(PIP) install -r requirements.txt

dev:
	$(PIP) install -r requirements-dev.txt
	pre-commit install

fmt:
	black .
	isort .

lint:
	ruff .

test:
	pytest -q

build:
	$(PY) -m build
