from pydev_poetry.hello import greet


def test_greet():
    assert greet.greet("Hi")
