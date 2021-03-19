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

```
$ make build
rm -rf .venv
docker build -t pydev-poetry .
[+] Building 0.2s (20/20) FINISHED
 => [internal] load build definition from Dockerfile                                                     0.0s
 => => transferring dockerfile: 4.18kB                                                                   0.0s
 => [internal] load .dockerignore                                                                        0.0s
 => => transferring context: 57B                                                                         0.0s
 => [internal] load metadata for docker.io/nvidia/cuda:11.1-cudnn8-runtime-ubuntu20.04                   0.0s
 => [ 1/15] FROM docker.io/nvidia/cuda:11.1-cudnn8-runtime-ubuntu20.04                                   0.0s
 => [internal] load build context                                                                        0.0s
 => => transferring context: 127.47kB                                                                    0.0s
 => CACHED [ 2/15] RUN apt-get update -y &&     apt-get install -y --no-install-recommends     git       0.0s
 => CACHED [ 3/15] RUN apt-get update &&     curl -sL https://deb.nodesource.com/setup_14.x | bash - &&  0.0s
 => CACHED [ 4/15] RUN cd $(dirname $(which python3.8)) && rm python3 && ln -s python3.8 python3         0.0s
 => CACHED [ 5/15] RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python3                           0.0s
 => CACHED [ 6/15] RUN adduser --disabled-password     --gecos "Default user"     --uid 1000     jovyan  0.0s
 => CACHED [ 7/15] WORKDIR /work/                                                                        0.0s
 => CACHED [ 8/15] RUN mkdir -p /work/                                                                   0.0s
 => CACHED [ 9/15] RUN chown -R 1000 /work/                                                              0.0s
 => CACHED [10/15] COPY pyproject.toml poetry.toml poetry.lock /work/                                    0.0s
 => CACHED [11/15] RUN pip3 --disable-pip-version-check     install poetry &&     poetry install --no-r  0.0s
 => CACHED [12/15] RUN poetry run jupyter contrib nbextension install --user &&     poetry run jupyter   0.0s
 => CACHED [13/15] RUN poetry run jupyter labextension install @jupyterlab/toc --no-build &&     poetry  0.0s
 => CACHED [14/15] RUN mkdir -p /home/jovyan/.jupyter/lab/user-settings/@jupyterlab/apputils-extension   0.0s
 => CACHED [15/15] RUN mkdir -p /home/jovyan/.jupyter/lab/user-settings/@jupyterlab/notebook-extension   0.0s
 => exporting to image                                                                                   0.0s
 => => exporting layers                                                                                  0.0s
 => => writing image sha256:409f07605b0f9751c9b936441ce4f71ba56b809bd9bdfcef63edab0f9e4bf083             0.0s
 => => naming to docker.io/library/pydev-poetry                                                          0.0s
docker run --name pydevcontainer pydev-poetry
docker cp pydevcontainer:/work/.venv .venv
docker stop pydevcontainer && docker rm pydevcontainer
pydevcontainer
pydevcontainer
docker-compose build
python uses an image, skipping
jupyter uses an image, skipping
lab uses an image, skipping
lab-gpu uses an image, skipping
docker-compose run --rm python poetry install
Creating pydev_poetry_python_run ... done
Installing dependencies from lock file

No dependencies to install or update

Installing the current project: pydevpoetry (0.1.0)
```

Great, you're good to go.

# Usage

## Running Python 

```
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

```
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

