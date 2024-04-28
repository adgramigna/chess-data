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
from game_detail
inner join ids_map on game_detail.surrogate_game_id = ids_map.surrogate_game_id
    and game_detail.is_white_move = ids_map.is_white

