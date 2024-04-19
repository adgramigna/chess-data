import chess
import chess.pgn
import io
import polars as pl
from datetime import datetime


def parse_nags(nags):
    if len(nags) == 0:
        return 0
    if len(nags) > 1:
        return None
    return nags.pop()


def parse_engine_eval(node):
    engine_eval_base = node.eval().white()
    if engine_eval_base.is_mate():
        engine_score = engine_eval_base.mate()
    else:
        engine_score = engine_eval_base.score() / 100

    return engine_score


def get_chess_game(pgn_string):
    return chess.pgn.read_game(io.StringIO(pgn_string))


def parse_game_headers(chess_game):
    game_headers = chess_game.headers
    game_headers_dict = {}
    game_headers_dict["surrogate_game_id"] = (
        f"{game_headers.get('Event')}_{game_headers.get('Round')}_{game_headers.get('WhiteFideId')}_{game_headers.get('BlackFideId')}"
    )
    game_headers_dict["event"] = game_headers.get("Event")
    game_headers_dict["site"] = game_headers.get("Site")
    game_headers_dict["date"] = datetime.strptime(
        game_headers.get("Date"), "%Y.%m.%d"
    ).date()
    game_headers_dict["round"] = game_headers.get("Round")
    game_headers_dict["white"] = game_headers.get("White")
    game_headers_dict["black"] = game_headers.get("Black")
    game_headers_dict["result"] = game_headers.get("Result")
    game_headers_dict["white_elo"] = int(game_headers.get("WhiteElo"))
    game_headers_dict["white_title"] = game_headers.get("WhiteTitle")
    game_headers_dict["white_fide_id"] = int(game_headers.get("WhiteFideId"))
    game_headers_dict["black_elo"] = int(game_headers.get("BlackElo"))
    game_headers_dict["black_title"] = game_headers.get("BlackTitle")
    game_headers_dict["black_fide_id"] = int(game_headers.get("BlackFideId"))
    game_headers_dict["variant"] = game_headers.get("Variant")
    game_headers_dict["eco"] = game_headers.get("ECO")
    game_headers_dict["opening"] = game_headers.get("Opening")
    game_headers_dict["annotator"] = game_headers.get("Annotator")

    return game_headers_dict


def initialize_move_info(lichess_game_info):
    move_info = {
        "surrogate_game_id": lichess_game_info.get("surrogate_game_id"),
        "row_number": [],
        "move_number": [],
        "starting_square": [],
        "san": [],
        "clock_time": [],
        "engine_evaluation_score": [],
        "is_checkmate_countdown": [],
        "is_white_move": [],
        "nag": [],
        "comment": [],
        "fen": [],
    }

    return move_info


def parse_pgn_moves(chess_game, lichess_game_info):
    move_info = initialize_move_info(lichess_game_info)
    # Accuracy helpful blog https://lichess.org/@/JoaoTx/blog/exploring-the-python-chess-module/P0nb4FEs
    for j, node in enumerate(chess_game.mainline()):
        move_info["fen"].append(node.board().fen())
        move_info["clock_time"].append(node.clock())
        move_info["is_checkmate_countdown"].append(node.eval().white().is_mate())
        move_info["engine_evaluation_score"].append(parse_engine_eval(node))
        move_info["nag"].append(parse_nags(node.nags))
        move_info["is_white_move"].append(not node.turn())
        move_info["row_number"].append(j + 1)
        move_info["move_number"].append(j // 2 + 1)
        move_info["starting_square"].append(chess.square_name(node.move.from_square))
        move_info["san"].append(node.san())
        move_info["comment"].append(node.comment)

    return move_info


def create_pgn_dataframes(pgn_string):
    chess_game = get_chess_game(pgn_string)

    lichess_game_info = parse_game_headers(chess_game)
    lichess_game_info_df = pl.DataFrame(lichess_game_info)

    lichess_move_info = parse_pgn_moves(chess_game, lichess_game_info)
    lichess_moves_df = pl.DataFrame(lichess_move_info)

    return [lichess_game_info_df, lichess_moves_df]
