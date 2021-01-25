.phony: all, build, test

all: build

build:
	rm -f poetry.lock
	docker-compose build
	docker-compose run --rm python poetry install

test:
	poetry run pytest
