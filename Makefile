.phony: all, build, test, clean

all: build

build:
	rm -f poetry.lock
	docker-compose build
	docker-compose run --rm python poetry install

test:
	poetry run pytest

clean:
	rm -f poetry.lock
	docker-compose down
