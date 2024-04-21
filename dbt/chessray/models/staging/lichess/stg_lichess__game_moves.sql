select 
    surrogate_move_id,
    surrogate_game_id,
    row_number as move_row_number,
    move_number,
    starting_square,
    san,
    clock_time,
    engine_evaluation_score,
    is_checkmate_countdown,
    is_white_move,
    nag,
    comment,
    fen
from {{ source('lichess', 'game_moves') }}
