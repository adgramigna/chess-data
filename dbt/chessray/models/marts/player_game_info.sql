with game_players as (
    select * from {{ ref('stg_lichess__game_players') }}
),

game_outline as (
    select * from {{ ref('stg_lichess__rounds_detail') }}
),

game_detail as (
    select * from {{ ref('int_moves_to_game_player_grain') }}
),

surrogate_game_id_map as (
    select * from {{ ref('int_surrogate_game_id_to_game_id_map') }}
),

rounds_outline as (
    select * from {{ ref('stg_lichess__rounds_outline') }}
)


select 
    md5(game_players.player_name || '_' || game_players.game_id) as id,
    game_players.player_name,
    game_players.colloquial_name,
    game_players.game_id,
    game_outline.round_id,
    rounds_outline.tournament_id,
    case
        when is_draw then 0.5
        when (game_players.is_white and game_outline.is_white_victory)
        or (not game_players.is_white and game_outline.is_black_victory) then 1
        else 0
    end as num_points,
    game_players.color,
    game_players.is_white,
    game_detail.* exclude(surrogate_game_id, is_white)
from game_players
inner join game_outline on game_players.game_id = game_outline.game_id
inner join rounds_outline on game_outline.round_id = rounds_outline.round_id
inner join surrogate_game_id_map on game_players.game_id = surrogate_game_id_map.game_id
inner join game_detail on surrogate_game_id_map.surrogate_game_id = game_detail.surrogate_game_id
    and game_players.is_white = game_detail.is_white



