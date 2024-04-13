from msgspec import Struct
from typing import Optional
# from datetime import datetime


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


class Leaderboard(Struct):
    name: str
    score: float
    played: int
    rating: int
    title: str
    fideId: int
    fed: str
