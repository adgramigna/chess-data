from msgspec import Struct
from typing import Optional


class Leaderboard(Struct):
    name: str
    score: float
    played: int
    title: str
    fed: Optional[str] = None
    fideId: Optional[int] = None
    rating: Optional[int] = None
