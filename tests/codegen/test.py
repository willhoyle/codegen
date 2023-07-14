from os import path
import sys


# codegen: decorator
def decorator():
    return lambda _: _


class Class:
    pass


@decorator()
class DecoratedClass:
    pass
