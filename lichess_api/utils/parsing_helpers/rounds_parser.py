import polars as pl
import json
from utils.classes.rounds import Game
from msgspec.json import decode


def parse_broadcast_tournament_rounds(rounds_detail_data, tournament_id, round_id):
    rounds_detail_json = []
    players_json = []
    for i, game in enumerate(rounds_detail_data):
        rounds_detail_json_record = {}
        rounds_detail_json_record["game_id"] = game.id
        rounds_detail_json_record["tournament_id"] = tournament_id
        rounds_detail_json_record["round_id"] = round_id
        rounds_detail_json_record["fen"] = game.fen
        rounds_detail_json_record["last_move"] = game.lastMove
        rounds_detail_json_record["status"] = game.status
        rounds_detail_json_record["think_time"] = game.thinkTime

        rounds_detail_json.append(rounds_detail_json_record)

        for j, player in enumerate(game.players):
            player_json_record = {}
            player_json_record["name"] = player.name
            player_json_record["game_id"] = game.id
            player_json_record["tournament_id"] = tournament_id
            player_json_record["round_id"] = round_id
            player_json_record["title"] = player.title
            player_json_record["color"] = "White" if j == 0 else "Black"

            players_json.append(player_json_record)

    return rounds_detail_json, players_json


def create_broadcast_rounds_detail_dataframes(json_data, tournament_id, round_id):
    lichess_tournament_rounds_detail = decode(
        json.dumps(json_data["games"]), type=list[Game]
    )
    lichess_tournament_rounds_detail_final, lichess_players_final = (
        parse_broadcast_tournament_rounds(
            lichess_tournament_rounds_detail, tournament_id, round_id
        )
    )

    lichess_rounds_detail_df = pl.DataFrame(lichess_tournament_rounds_detail_final)
    lichess_players_df = pl.DataFrame(lichess_players_final)

    return [lichess_rounds_detail_df, lichess_players_df]
