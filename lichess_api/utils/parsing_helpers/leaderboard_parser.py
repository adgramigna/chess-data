import polars as pl
import json
from utils.classes.leaderboard import Leaderboard
from msgspec.json import decode


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
