import requests
import polars as pl
import json
import os
from dotenv import load_dotenv
from utils.classes import Tour, Round, Leaderboard
from msgspec.json import decode

load_dotenv()


def call_lichess_broadcasts_api(
    broadcast_tournament_id, round_info=None, leaderboard=False
):
    headers = {
        "Content-Type": "application/json",
        "X-Api-Key": os.environ.get("LICHESS_API_KEY"),
    }

    if round_info is None:
        if not leaderboard:
            lichess_broadcast_endpoint = (
                f"https://lichess.org/api/broadcast/{broadcast_tournament_id}"
            )
        else:
            lichess_broadcast_endpoint = (
                f"https://lichess.org/broadcast/{broadcast_tournament_id}/leaderboard"
            )
    else:
        lichess_broadcast_endpoint = f"https://lichess.org/api/broadcast/{round_info[0]}/{round_info[1]}/{round_info[2]}"

    response = requests.get(lichess_broadcast_endpoint, headers=headers)
    result_json = response.json()

    return result_json, lichess_broadcast_endpoint


def parse_broadcast_tournament_base(tour_data, rounds_data, tournament_id):
    tour_json = {}
    tour_json["tournament_id"] = tour_data.id
    tour_json["name"] = tour_data.name
    tour_json["slug"] = tour_data.slug
    tour_json["created_at"] = tour_data.createdAt
    tour_json["tier"] = tour_data.tier
    tour_json["image"] = tour_data.image
    tour_json["url"] = tour_data.url
    tour_json["leaderboard"] = tour_data.leaderboard

    rounds_json = []
    for i, chess_round in enumerate(rounds_data):
        round_json_record = {}
        round_json_record["round_id"] = chess_round.id
        round_json_record["tournament_id"] = tournament_id
        round_json_record["name"] = chess_round.name
        round_json_record["slug"] = chess_round.slug
        round_json_record["created_at"] = chess_round.createdAt
        round_json_record["starts_at"] = chess_round.startsAt
        round_json_record["url"] = chess_round.url
        round_json_record["finished"] = chess_round.finished

        rounds_json.append(round_json_record)

    return tour_json, rounds_json


def create_broadcast_base_dataframes(json_data, tournament_id):
    lichess_tour = decode(json.dumps(json_data["tour"]), type=Tour)
    lichess_rounds = decode(json.dumps(json_data["rounds"]), type=list[Round])

    lichess_tour_final, lichess_rounds_final = parse_broadcast_tournament_base(
        lichess_tour, lichess_rounds, tournament_id
    )

    lichess_tour_df = pl.DataFrame(lichess_tour_final)
    lichess_rounds_df = pl.DataFrame(lichess_rounds_final)

    return [lichess_tour_df, lichess_rounds_df]


def parse_broadcast_tournament_leaderboard(leaderboard_data, tournament_id):
    player_json = []
    for i, player_info in enumerate(leaderboard_data):
        player_json_record = {}
        player_json_record["fide_id"] = player_info.fideId
        player_json_record["tournament_id"] = tournament_id
        player_json_record["name"] = player_info.name
        player_json_record["score"] = player_info.score
        player_json_record["number_of_rounds_played"] = player_info.played
        player_json_record["rating"] = player_info.rating
        player_json_record["title"] = player_info.title
        player_json_record["federation"] = player_info.fed

        player_json.append(player_json_record)

    return player_json


def create_broadcast_leaderboard_dataframe(json_data, tournament_id):
    lichess_tournament_leaderboard = decode(
        json.dumps(json_data), type=list[Leaderboard]
    )
    lichess_tournament_leaderboard_final = parse_broadcast_tournament_leaderboard(
        lichess_tournament_leaderboard, tournament_id
    )

    lichess_leaderboard_df = pl.DataFrame(lichess_tournament_leaderboard_final)

    return [lichess_leaderboard_df]
