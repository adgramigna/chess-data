with winning_advantages as (
    select
        surrogate_game_id,
        sum(case when is_white_winning_advantage then 1 else 0 end) as num_times_white_winning_advantage,
        max(case when is_black_winning_advantage then 1 else 0 end) as num_times_black_winning_advantage,
    from {{ ref('stg_lichess__game_moves') }}
    group by 1
),

game_players as (
    select 
        player_name,
        is_white_move as is_white,
        game_id,
        surrogate_game_id
    from {{ ref('int_player_moves_with_ids') }}
    group by all
),

ids_map as (
    select 
        surrogate_game_id,
        game_id 
    from {{ ref('int_ids_map') }}
    group by all
)


select
    game_players.player_name,
    game_players.is_white,
    game_players.game_id,
    case
        when game_players.is_white then winning_advantages.num_times_white_winning_advantage
        when not game_players.is_white then winning_advantages.num_times_black_winning_advantage,
    end as num_times_gaining_winning_advantage,
from game_players
inner join ids_map on game_players.game_id = ids_map.game_id
    and game_players.player_name = ids_map.player_name
inner join winning_advantages on ids_map.surrogate_game_id = winning_advantages.surrogate_game_id
