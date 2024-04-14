import polars as pl
import json
from dotenv import load_dotenv
from utils.classes.tournament import Tour, Round
from msgspec.json import decode

load_dotenv()


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
