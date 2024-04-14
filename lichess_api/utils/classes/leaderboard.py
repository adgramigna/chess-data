from msgspec import Struct


class Leaderboard(Struct):
    name: str
    score: float
    played: int
    rating: int
    title: str
    fideId: int
    fed: str
