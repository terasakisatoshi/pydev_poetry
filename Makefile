.phony: all

all: build

build:
	rm -f poetry.lock
	docker-compose build
	docker-compose run --rm python poetry install
