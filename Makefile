.phony: all, build, test, clean

all: build

build:
	rm -f poetry.lock
	rm -rf .venv
	rm -f envpath.txt
	docker build -t pydev-poetry .
	docker run --name pydevcontainer pydev-poetry poetry env info -p >> envpath.txt
	docker cp pydevcontainer:$(shell cat envpath.txt) .venv
	docker stop pydevcontainer && docker rm pydevcontainer
	docker-compose build
	docker-compose run --rm python poetry install

test:
	docker-compose run --rm python poetry run pytest

clean:
	rm -f poetry.lock
	rm -r .venv
	docker-compose down
