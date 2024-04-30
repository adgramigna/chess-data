with game_detail as (
    select
        surrogate_game_id,
        max(is_e4_game) as is_e4_game,
        max(is_d4_game) as is_d4_game,
    from {{ ref('stg_lichess__game_moves') }}
    group by 1
)


select
    surrogate_game_id,
    case
        when is_e4_game then 'e4'
        when is_d4_game then 'd4'
        else 'Other'
    end as first_move
from game_detail