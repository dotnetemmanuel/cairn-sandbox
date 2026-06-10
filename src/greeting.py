"""Simple greeting helpers used to exercise Cairn's diff/review panes."""


def greet(name: str) -> str:
    """Return a greeting for the given name."""
    if not name:
        name = "stranger"
    return f"Hello, {name}!"


def farewell(name: str) -> str:
    """Return a farewell for the given name."""
    return f"Goodbye, {name}."


if __name__ == "__main__":
    print(greet("world"))
    print(farewell("world"))
