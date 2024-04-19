from msgspec import Struct
from typing import Optional


class Player(Struct):
    name: str
    title: str
    rating: int
    fed: str
    clock: Optional[int] = None  # centiseconds, time is seconds * 100


class Game(Struct):
    id: str
    name: str
    fen: str
    players: list[Player]
    lastMove: str
    status: str  # "*" if game not settled
    thinkTime: Optional[int] = None  # When game is still occurring
