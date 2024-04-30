with game_detail as (
    select * from {{ ref('stg_lichess__game_moves') }}
),

ids_map as (
    select * from {{ ref('int_ids_map') }}
)

select
    game_detail.surrogate_move_id,
    game_detail.is_white_move,
    ids_map.player_name,
    ids_map.game_id,
    ids_map.round_id,
    ids_map.tournament_id,
    game_detail.starting_square,
    game_detail.san,
    game_detail.is_endgame,
    game_detail.time_pressure_category,
    game_detail.move_row_number,
    game_detail.move_number,
    game_detail.piece_moved,
    game_detail.is_check,
    game_detail.is_checkmate,
    game_detail.is_capture,
    game_detail.move_accuracy,
    game_detail.time_spent_on_move,
    game_detail.is_checkmate_countdown,
    game_detail.engine_evaluation_score,
    game_detail.color_with_winning_advantage,
    game_detail.is_given_away_winning_advantage,
    game_detail.has_winning_advantage,
    game_detail.is_lost_winning_advantage,
    game_detail.is_poor_move,
    game_detail.nag,
    game_detail.comment,
    game_detail.fen
from game_detail
inner join ids_map on game_detail.surrogate_game_id = ids_map.surrogate_game_id
    and game_detail.is_white_move = ids_map.is_white

