from msgspec import Struct
from typing import Optional


class Player(Struct):
    name: str
    title: str
    rating: int
    clock: int  # centiseconds, time is seconds * 100
    fed: str


class Game(Struct):
    id: str
    name: str
    fen: str
    players: list[Player]
    lastMove: str
    status: str  # "*" if game not settled
    thinkTime: Optional[int] = None  # On
