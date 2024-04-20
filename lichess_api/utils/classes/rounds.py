from msgspec import Struct
from typing import Optional


class Player(Struct):
    name: str
    fed: Optional[str] = None
    rating: Optional[int] = None
    title: Optional[str] = None
    clock: Optional[int] = None  # centiseconds, time is seconds * 100


class Game(Struct):
    id: str
    name: str
    players: list[Player]
    status: str  # "*" if game not settled
    lastMove: Optional[str] = None
    fen: Optional[str] = None  # Game hasn't started
    thinkTime: Optional[int] = None  # When game is still occurring
