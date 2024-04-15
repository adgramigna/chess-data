import requests
import os
import logging
from dotenv import load_dotenv

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("logger")

load_dotenv()


def call_lichess_broadcasts_api(endpoint_type, **kwargs):
    headers = {
        "Content-Type": "application/json",
        "X-Api-Key": os.environ.get("LICHESS_API_KEY"),
    }

    tournament_id = kwargs.get("broadcast_tournament_id")
    tournament_slug = kwargs.get("broadcast_tournament_slug")
    round_slug = kwargs.get("broadcast_round_slug")
    round_id = kwargs.get("broadcast_round_id")

    if endpoint_type == "tournament":
        lichess_broadcast_endpoint = (
            f"https://lichess.org/api/broadcast/{tournament_id}"
        )
    elif endpoint_type == "leaderboard":
        lichess_broadcast_endpoint = (
            f"https://lichess.org/broadcast/{tournament_id}/leaderboard"
        )
    elif endpoint_type == "round":
        lichess_broadcast_endpoint = f"https://lichess.org/api/broadcast/{tournament_slug}/{round_slug}/{round_id}"
    elif endpoint_type == "pgn":
        lichess_broadcast_endpoint = (
            f"https://lichess.org/api/broadcast/round/{round_id}.pgn"
        )
    else:
        lichess_broadcast_endpoint = None
        logger.error("Invalid Endpoint URL")
    response = requests.get(lichess_broadcast_endpoint, headers=headers)
    if endpoint_type != "pgn":
        result = response.json()
    else:
        result = response.text

    return result, lichess_broadcast_endpoint
