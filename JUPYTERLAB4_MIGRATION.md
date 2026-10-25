# JupyterLab 4 security migration

The environment now uses JupyterLab 4.6.4 and its compatible prebuilt Python-packaged extensions. The CUDA 11.1 / cuDNN 8 / Ubuntu 20.04 base, Python 3.11, and scientific package versions are unchanged.

## Preserved

- Notebook editing, execution, HTML/Markdown export, built-in table of contents and line numbers.
- Jupytext 1.19.6, ipywidgets 8.1.9 and JupyterLab code formatter 3.1.0 through prebuilt extensions (no Node source build).
- Classic Notebook 6.5.7 and classic nbextensions remain available; this is not a Notebook 7 migration.

## Removed incompatible/unsupported Lab extensions

- Sublime keymap (`@z-m-k/jupyterlab_sublime`). Use the standard Lab keymap.
- Monokai++ (`@hokyjack/jupyterlab-monokai-plus`). The default is now the built-in **JupyterLab Dark** theme.
- Variable inspector (`lckr-jupyterlab-variableinspector`). Latest 3.2.4 conflicts with Lab 4.6.4: its `@jupyter/web-components >=0.15,<0.16` requirement conflicts with Lab's `>=0.16.6,<0.17`. Classic Notebook's separate varInspector extension remains configured.

Legacy `jupyter labextension install`/`lab build` commands and the now-unnecessary Node 14 installer were removed. The table of contents is built in; widget and Jupytext frontend packages arrive from the locked Python dependencies.

## Validation and limits

Python CI checks the locked install, dependency consistency, tests, Black, mypy, Matplotlib/OpenCV image smoke, notebook kernel execution and a Lab HTTP startup/login page. Compatibility tests also cover Classic Notebook CLI, Jupytext roundtrip, widget state, formatter integration, exports, and TLS verification defaults.

Kernel and HTTP socket tests run on GitHub Actions; restricted local sandbox sockets do not support kernel execution. Passing HTTP startup is not full browser interaction testing. Full Docker image compilation, CUDA/GPU execution and interactive browser extension behavior remain unverified. Rebuild existing container images to use the updated lock and extension set.
