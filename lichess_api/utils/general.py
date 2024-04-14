import requests
import os
from dotenv import load_dotenv

load_dotenv()


def call_lichess_broadcasts_api(
    broadcast_tournament_id=None, round_info=None, leaderboard=False, round_pgn=False
):
    headers = {
        "Content-Type": "application/json",
        "X-Api-Key": os.environ.get("LICHESS_API_KEY"),
    }

    if round_info is None:
        if leaderboard:
            lichess_broadcast_endpoint = (
                f"https://lichess.org/broadcast/{broadcast_tournament_id}/leaderboard"
            )
        else:
            lichess_broadcast_endpoint = (
                f"https://lichess.org/api/broadcast/{broadcast_tournament_id}"
            )
    elif round_pgn:
        lichess_broadcast_endpoint = (
            f"https://lichess.org/api/broadcast/round/{round_info[-1]}.pgn"
        )
    else:
        lichess_broadcast_endpoint = f"https://lichess.org/api/broadcast/{round_info[0]}/{round_info[1]}/{round_info[2]}"

    response = requests.get(lichess_broadcast_endpoint, headers=headers)
    result_json = response.json()

    return result_json, lichess_broadcast_endpoint
