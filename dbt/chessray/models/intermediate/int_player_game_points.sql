with game_players as (
    select * from {{ ref('stg_lichess__game_players') }}
),

game_outline as (
    select * from {{ ref('stg_lichess__rounds_detail') }}
)

select
    game_players.player_name,
    game_players.game_id,
    case
        when game_outline.is_draw then 0.5
        when (game_players.is_white and game_outline.is_white_victory)
        or (not game_players.is_white and game_outline.is_black_victory) then 1
        else 0
    end as num_points
from game_players
inner join game_outline on game_players.game_id = game_outline.game_id