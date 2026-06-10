from src.greeting import greet, farewell


def test_greet_named():
    assert greet("Ada") == "Hello, Ada!"


def test_greet_empty_defaults_to_stranger():
    assert greet("") == "Hello, stranger!"


def test_farewell():
    assert farewell("Ada") == "Goodbye, Ada."
