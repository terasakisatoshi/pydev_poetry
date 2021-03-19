# pydev_poetry

- Python workflow utilize [Poetry](https://python-poetry.org/), [Docker](https://www.docker.com/) and [VSCode](https://code.visualstudio.com/). They will accelerate your development.
- It is tested on Mac and Ubuntu20.04

# Prerequisite

- Please install Make, Docker and VSCode by yourself.
  - https://formulae.brew.sh/formula/make
  - https://docs.docker.com/get-docker/
    - See also https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-nvidia-container-toolkit
  - https://docs.docker.com/compose/install/
  - https://code.visualstudio.com/
- Make sure the following commands are valid on your system:
- We will use poetry which will be installed inside a container of Docker.

```console
$ make --help
$ docker --help
$ docker-compose --help
```

# Setup environment

- Just run:

```console
$ make build
```

Great, you're good to go.

# Usage

## Running Python 

```console
$ docker-compose run --rm python
Creating pydev_poetry_python_run ... done
print hPython 3.8.5 (default, Jan 27 2021, 15:41:15)
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print("Hello")
Hello
>>>
```

## Jupyter Lab

```console
$ docker-compose up lab
Creating pydev-poetry-lab ... done
Attaching to pydev-poetry-lab
...
...
...
pydev-poetry-lab |     To access the server, open this file in a browser:
pydev-poetry-lab |         file:///home/jovyan/.local/share/jupyter/runtime/jpserver-1-open.html
pydev-poetry-lab |     Or copy and paste one of these URLs:
pydev-poetry-lab |         http://49a61b38e6da:8888/lab?token=xxxxxxxxxxxxxxxxxxx
pydev-poetry-lab |      or http://127.0.0.1:8888/lab?token=xxxxxxxxxxxxxxxxxxx
```

- You'll see a message like above. Then open your web browser go to `http://127.0.0.1:8888/lab?token=xxxxxxxxxxxxxxxxxxx`

# Clean up

```console
$ make clean
$ # or
$ docker-compose down
```

