PY=python
PIP=pip

.PHONY: install dev fmt lint test build check

install:
	$(PIP) install -e .

dev:
	$(PIP) install -e ".[dev]"
	pre-commit install

fmt:
	ruff format .
	ruff check --fix .

lint:
	ruff check .

check:
	ruff check .
	mypy src/

test:
	pytest -q

build:
	$(PY) -m build
