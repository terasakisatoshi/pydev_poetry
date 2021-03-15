.phony: all, build, test, clean

all: build

build:
	rm -rf .venv
	docker build -t pydev-poetry .
	docker run --name pydevcontainer pydev-poetry
	docker cp pydevcontainer:/workspaces/.venv .venv
	docker stop pydevcontainer && docker rm pydevcontainer
	docker-compose build
	docker-compose run --rm python poetry install

test:
	docker-compose run --rm python poetry run pytest

clean:
	rm -r .venv
	docker-compose down
