select 
    surrogate_move_id,
    move_row_number,
    move_number,
    piece_moved,
    is_check,
    is_checkmate,
    is_capture,
    white_win_percentage,
    black_win_percentage,
    move_accuracy,
    clock_time,
    time_pressure_category,
    engine_evaluation_score,
    is_checkmate_countdown,
    is_white_move,
    nag,
    comment,
    fen,
    is_endgame
from {{ ref('stg_lichess__game_moves') }}

