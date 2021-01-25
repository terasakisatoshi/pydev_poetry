# pydev_poetry

# Install poetry

```
$ pip3 install poetry
```

# How to use poetry

```console
$ poetry run python -c "import sys; print(sys.version)"
3.8.6 (default, Oct  8 2020, 14:06:32)
[Clang 12.0.0 (clang-1200.0.32.2)]
```

or 

```console
$ poetry shell
(pydevpoetry-Py4rDnWz-py3.8) pydev_poetry$ python -c "import sys; print(sys.version)"
3.8.6 (default, Oct  8 2020, 14:06:32)
[Clang 12.0.0 (clang-1200.0.32.2)]
```

# Docker

```console
$ make
```

# Getting version of this package

- [How to get version from pyproject.toml from python app ?](https://github.com/python-poetry/poetry/issues/273#issuecomment-401983643) might be helpful.


```python
>>> import pkg_resources
>>> pkg_resources.get_distribution('pydevpoetry').version
```

# Testing using pytest

```console
poetry run pytest
```

