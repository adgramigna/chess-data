from msgspec import Struct
from typing import Optional


class Tour(Struct):
    id: str
    name: str
    slug: str
    description: str
    createdAt: int
    tier: int
    markup: str
    url: str
    leaderboard: Optional[bool] = None
    image: Optional[str] = None


class Round(Struct):
    id: str
    name: str
    slug: str
    createdAt: int
    startsAt: int
    url: str
    finished: Optional[bool] = None
