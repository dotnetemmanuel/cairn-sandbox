"""Greeting helpers used to exercise Cairn's diff/review panes.

This module is intentionally a little long so that diffs against it can
span multiple hunks — handy for testing n/N hunk navigation.
"""

from datetime import datetime

DEFAULT_NAME = "stranger"


def greet(name: str) -> str:
    """Return a greeting for the given name."""
    if not name:
        name = DEFAULT_NAME
    return f"Hey there, {name}! 👋"


def farewell(name: str) -> str:
    """Return a farewell for the given name."""
    if not name:
        name = DEFAULT_NAME
    return f"Take care, {name} — see you soon! 🙂"


def time_of_day(hour: int) -> str:
    """Map an hour (0-23) to a coarse part of the day."""
    if hour < 6:
        return "night"
    if hour < 12:
        return "morning"
    if hour < 18:
        return "afternoon"
    return "evening"


def time_greeting(name: str, hour: int) -> str:
    """Greet someone with a time-appropriate salutation."""
    part = time_of_day(hour)
    return f"Good {part}, {name or DEFAULT_NAME}! Hope you're doing well. ☀️"


def shout(message: str) -> str:
    """Return the message in an emphatic form."""
    return message.upper() + "!!!"


if __name__ == "__main__":
    now = datetime.now()
    print(greet("world"))
    print(time_greeting("world", now.hour))
    print(shout("welcome"))
    print(farewell("world"))
