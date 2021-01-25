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
    python3.8 \
    libpython3.8-dev \
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

# modify default python3 as python3.8
RUN cd $(dirname $(which python3.8)) && rm python3 && ln -s python3.8 python3
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python3

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

WORKDIR /workspace
RUN mkdir -p /workspace
RUN chown -R ${NB_UID} /workspace

USER ${NB_USER}

ENV PATH=${HOME}/.local/bin:$PATH
ENV JUPYTERHUB_SINGLEUSER_APP='jupyter_server.serverapp.ServerApp'

RUN pip3 install \
    # Install tools for Jupyter Notebook/Lab
    jupyter \
    jupyterlab \
    jupytext \
    ipywidgets \
    jupyter-contrib-nbextensions \
    jupyter-nbextensions-configurator \
    # Install tools for Development \
    pytest autopep8 black isort --user \
    && \
    echo Done

# Install/enable extension for Jupyter Notebook users
RUN jupyter contrib nbextension install --user && \
    jupyter nbextensions_configurator enable --user && \
    # enable extensions what you want
    jupyter serverextension enable jupytext --user && \
    jupyter nbextension enable code_prettify/autopep8 --user && \
    jupyter nbextension enable select_keymap/main --user && \
    jupyter nbextension enable highlight_selected_word/main --user&& \
    jupyter nbextension enable toggle_all_line_numbers/main --user && \
    jupyter nbextension enable varInspector/main --user && \
    jupyter nbextension enable toc2/main --user && \
    jupyter nbextension enable equation-numbering/main --user && \
    jupyter nbextension enable execute_time/ExecuteTime --user && \
    echo Done

RUN pip3 install \
    jupyterlab_code_formatter \
    lckr-jupyterlab-variableinspector \
    && \
    echo Done

# See https://github.com/ryantam626/jupyterlab_code_formatter/issues/193#issuecomment-761558266
# Also this creates /usr/etc/jupyter which requires root auth
USER root
RUN jupyter server extension enable --py jupyterlab_code_formatter
USER ${NB_USER}

# Install/enable extension for JupyterLab users
RUN jupyter labextension install @jupyterlab/toc --no-build && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter labextension install @z-m-k/jupyterlab_sublime --no-build && \
    jupyter labextension install @hokyjack/jupyterlab-monokai-plus --no-build && \
    jupyter labextension install jupyterlab-jupytext --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
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

RUN pip3 install opencv-python numpy matplotlib

