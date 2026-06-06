from enum import IntEnum


class ExitCode(IntEnum):
    OK = 0
    USAGE = 2
    FILESYSTEM = 3
    RUNTIME = 4
    STAGE = 5
    PROTOCOL = 6
    LOCKED = 7
    INTERNAL = 8
