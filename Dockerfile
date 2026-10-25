ARG CUDA_VERSION=11.1
ARG CUDNN_VERSION=8
ARG IMGTYPE=runtime
ARG OS=ubuntu20.04
FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-${IMGTYPE}-${OS}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3 \
    python3-pip \
    libpython3-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    liblzma-dev \
    uuid-dev \
    tk-dev \
    xz-utils \
    libopencv-dev \
    curl \
    wget \
    ca-certificates \
    tree \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# Keep the CUDA/Ubuntu base and system Python unchanged; build Python separately.
ARG PYTHON_VERSION=3.11.17
ARG PYTHON_SHA256=bfb74ad39efae27cda510f134ab408e00f9992c56851cfc0b1cdb5646da11599
RUN curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz" -o /tmp/python.tar.xz && \
    echo "${PYTHON_SHA256}  /tmp/python.tar.xz" | sha256sum -c - && \
    mkdir /tmp/python-src && tar -xJf /tmp/python.tar.xz -C /tmp/python-src --strip-components=1 && \
    cd /tmp/python-src && ./configure --prefix=/opt/python311 --with-ensurepip=install && \
    make -j2 && make altinstall && \
    ln -s python3.11 /opt/python311/bin/python3 && \
    ln -s pip3.11 /opt/python311/bin/pip3 && \
    rm -rf /tmp/python-src /tmp/python.tar.xz
ENV PATH=/opt/python311/bin:/opt/poetry/bin:$PATH
RUN python3 -c "import ssl, sqlite3, bz2, lzma, ctypes; import sys; assert sys.version_info[:2] == (3, 11)" && \
    python3 -m venv /opt/poetry && \
    /opt/poetry/bin/python -m pip install --no-cache-dir poetry==2.2.1

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

WORKDIR /work/
RUN mkdir -p /work/
RUN chown -R ${NB_UID} /work/

USER ${NB_USER}

ENV PATH=${HOME}/.local/bin:$PATH
ENV JUPYTERHUB_SINGLEUSER_APP='jupyter_server.serverapp.ServerApp'

#RUN pip3 install \
#    # Install tools for Jupyter Notebook/Lab
#    jupyter \
#    jupyterlab \
#    jupytext \
#    ipywidgets \
#    jupyter-contrib-nbextensions \
#    jupyter-nbextensions-configurator \
#    jupyterlab_code_formatter \
#    lckr-jupyterlab-variableinspector \
    # Install tools for development \
#    poetry autopep8 black isort \
#    --user \
#    && \
#    echo Done

COPY pyproject.toml poetry.toml poetry.lock /work/
RUN poetry env use /opt/python311/bin/python3.11 && \
    poetry install --no-root && \
    echo Done

# Install/enable extension for Jupyter Notebook users
RUN poetry run jupyter contrib nbextension install --user && \
    poetry run jupyter nbextensions_configurator enable --user && \
    # enable extensions what you want
    poetry run jupyter serverextension enable jupytext --user && \
    poetry run jupyter nbextension enable code_prettify/autopep8 --user && \
    poetry run jupyter nbextension enable select_keymap/main --user && \
    poetry run jupyter nbextension enable highlight_selected_word/main --user&& \
    poetry run jupyter nbextension enable toggle_all_line_numbers/main --user && \
    poetry run jupyter nbextension enable varInspector/main --user && \
    poetry run jupyter nbextension enable toc2/main --user && \
    poetry run jupyter nbextension enable equation-numbering/main --user && \
    poetry run jupyter nbextension enable execute_time/ExecuteTime --user && \
    echo Done

# Install/enable extension for JupyterLab users
RUN poetry run jupyter labextension install @jupyterlab/toc --no-build && \
    poetry run jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    poetry run jupyter labextension install @z-m-k/jupyterlab_sublime --no-build && \
    poetry run jupyter labextension install @hokyjack/jupyterlab-monokai-plus --no-build && \
    poetry run jupyter labextension install jupyterlab-jupytext --no-build && \
    poetry run jupyter lab build -y && \
    poetry run jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf ${HOME}/.cache/yarn && \
    rm -rf ${HOME}/.node-gyp && \
    echo Done

# Set color theme Monokai++ by default (The selection is due to my hobby)
RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension && echo '\
{\n\
    "theme": "Monokai++"\n\
}\n\
\
' >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings

# Show line numbers by default
RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension && echo '\
{\n\
    "codeCellConfig": {\n\
        "lineNumbers": true,\n\
    },\n\
}\n\
\
' >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings

EXPOSE 8888
CMD ["poetry", "run", "python3"]
