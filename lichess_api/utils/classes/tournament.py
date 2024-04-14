from msgspec import Struct
from typing import Optional


class Tour(Struct):
    id: str
    name: str
    slug: str
    description: str
    createdAt: int
    tier: int
    image: str
    markup: str
    url: str
    leaderboard: Optional[bool] = None


class Round(Struct):
    id: str
    name: str
    slug: str
    createdAt: int
    startsAt: int
    url: str
    finished: Optional[bool] = None
