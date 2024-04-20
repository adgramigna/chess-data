import sys
import time
import logging
import polars as pl
import utils.parsing_helpers.tournament_parser as tournament_parser
import utils.parsing_helpers.leaderboard_parser as leaderboard_parser
import utils.parsing_helpers.rounds_parser as rounds_parser
import utils.parsing_helpers.pgn_parser as pgn_parser
import utils.general as general_util


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("logger")

tournament_id = sys.argv[1]
# tournament_id = "wEuVhT9c"  # 2024 Candidates tournament


def get_rounds_detail_dfs(
    row, tournament_slug, lichess_rounds_detail_df_all, lichess_players_df_all
):
    rounds_response, rounds_api_endpoint = general_util.call_lichess_broadcasts_api(
        "round",
        broadcast_tournament_slug=tournament_slug,
        broadcast_round_slug=row["slug"],
        broadcast_round_id=row["round_id"],
    )
    rounds_json = rounds_response.json()
    lichess_rounds_detail_df, lichess_players_df = (
        rounds_parser.create_broadcast_rounds_detail_dataframes(
            rounds_json, row["round_id"]
        )
    )

    lichess_rounds_detail_df_all = pl.concat(
        [lichess_rounds_detail_df_all, lichess_rounds_detail_df]
    )
    lichess_players_df_all = pl.concat([lichess_players_df_all, lichess_players_df])

    return lichess_rounds_detail_df_all, lichess_players_df_all


def get_pgn_dfs(row, lichess_game_headers_df_all, lichess_moves_df_all):
    round_pgn_response, round_pgn_endpoint = general_util.call_lichess_broadcasts_api(
        "pgn", broadcast_round_id=row["round_id"]
    )
    round_pgn_lists = round_pgn_response.text.split("\n\n\n")

    for game_pgn_string in round_pgn_lists:
        if game_pgn_string == "":
            continue
        lichess_game_headers_df, lichess_moves_df = pgn_parser.create_pgn_dataframes(
            game_pgn_string, row["round_id"]
        )

        lichess_game_headers_df_all = pl.concat(
            [lichess_game_headers_df_all, lichess_game_headers_df]
        )
        lichess_moves_df_all = pl.concat([lichess_moves_df_all, lichess_moves_df])

    return lichess_game_headers_df_all, lichess_moves_df_all


# Initial Tournament info
tournament_response, tournament_api_endpoint = general_util.call_lichess_broadcasts_api(
    "tournament", broadcast_tournament_id=tournament_id
)
tournament_json = tournament_response.json()
lichess_tour_df, lichess_rounds_outline_df = (
    tournament_parser.create_broadcast_base_dataframes(tournament_json, tournament_id)
)

tournament_slug = lichess_tour_df.select("slug").item()
has_leaderboard = lichess_tour_df.select("leaderboard").item()

# Leaderboard info
if has_leaderboard:
    leaderboard_response, leaderboard_api_endpoint = (
        general_util.call_lichess_broadcasts_api(
            "leaderboard", broadcast_tournament_id=tournament_id
        )
    )
    leaderboard_json = leaderboard_response.json()
    lichess_leaderboard_df = leaderboard_parser.create_broadcast_leaderboard_dataframe(
        leaderboard_json, tournament_id
    )[0]
else:
    lichess_leaderboard_df = pl.DataFrame()


# Headers, rounds, players, moves
lichess_game_headers_df_all = pl.DataFrame()
lichess_moves_df_all = pl.DataFrame()
lichess_rounds_detail_df_all = pl.DataFrame()
lichess_players_df_all = pl.DataFrame()
for row in lichess_rounds_outline_df.iter_rows(named=True):
    # Can't parse games which haven't started
    if time.time() * 1_000 < row["starts_at"]:  # starts_at is in millis
        continue
    logger.info(f"{row['slug']}")

    lichess_rounds_detail_df_all, lichess_players_df_all = get_rounds_detail_dfs(
        row, tournament_slug, lichess_rounds_detail_df_all, lichess_players_df_all
    )

    lichess_game_headers_df_all, lichess_moves_df_all = get_pgn_dfs(
        row, lichess_game_headers_df_all, lichess_moves_df_all
    )

# Export
general_util.export_to_s3(lichess_tour_df, tournament_id, "tournament")
general_util.export_to_s3(lichess_rounds_outline_df, tournament_id, "rounds_outline")
general_util.export_to_s3(lichess_leaderboard_df, tournament_id, "leaderboard")
general_util.export_to_s3(lichess_rounds_detail_df_all, tournament_id, "rounds_detail")
general_util.export_to_s3(lichess_players_df_all, tournament_id, "game_players")
general_util.export_to_s3(lichess_game_headers_df_all, tournament_id, "game_headers")
general_util.export_to_s3(lichess_moves_df_all, tournament_id, "game_moves")
