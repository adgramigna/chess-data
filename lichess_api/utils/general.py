import requests
import os
import logging
import s3fs
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

    return response, lichess_broadcast_endpoint


def export_to_s3(df, tournament_id, descriptor):
    if len(df) == 0:
        pass

    fs = s3fs.S3FileSystem(
        key=os.environ.get("AWS_ACCESS_KEY_ID"),
        secret=os.environ.get("AWS_SECRET_ACCESS_KEY"),
        client_kwargs={"region_name": os.environ.get("AWS_REGION")},
    )

    destination = (
        f"s3://lichess-broadcasts-api/tournaments/{tournament_id}/{descriptor}.parquet"
    )

    with fs.open(destination, mode="wb") as f:
        df.write_parquet(f)

    logger.info(f"Exported {descriptor} to s3: {tournament_id}")
