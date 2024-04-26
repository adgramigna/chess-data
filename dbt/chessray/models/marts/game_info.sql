with player_game_info as (
    select * from {{ ref('player_game_info') }}
),

game_outline as (
    select * from {{ ref('stg_lichess__rounds_detail') }}
),

game_headers as (
    select * from {{ ref('stg_lichess__game_headers') }}
),

surrogate_game_id_map as (
    select * from {{ ref('int_surrogate_game_id_to_game_id_map') }}
)

select 
    player_game_info.game_id,
    player_game_info.round_id,
    player_game_info.tournament_id,
    game_outline.game_status,
    game_headers.chess_variant,
    game_headers.opening_general,
    max(player_game_info.num_moves) as game_moves,
    sum(player_game_info.num_moves) as num_moves_both_sides,
    sum(player_game_info.num_moves_in_severe_time_pressure) as num_moves_in_severe_time_pressure,
    sum(player_game_info.num_moves_in_time_pressure) as num_moves_in_time_pressure,
    sum(player_game_info.num_moves_in_no_time_pressure) as num_moves_in_no_time_pressure,
    sum(player_game_info.num_captures) as num_captures,
    sum(player_game_info.num_checks_given) as num_checks_given,
    max(player_game_info.ends_in_checkmate) as ends_in_checkmate,
    sum(player_game_info.num_inaccuracies) as num_inaccuracies,
    sum(player_game_info.num_mistakes) as num_mistakes,
    sum(player_game_info.num_blunders) as num_blunders,
    sum(player_game_info.num_poor_moves) as num_poor_moves,
    sum(player_game_info.num_inaccuracies_under_time_pressure) as num_inaccuracies_under_time_pressure,
    sum(player_game_info.num_mistakes_under_time_pressure) as num_mistakes_under_time_pressure,
    sum(player_game_info.num_blunders_under_time_pressure) as num_blunders_under_time_pressure,
    sum(player_game_info.num_inaccuracies_under_severe_time_pressure) as num_inaccuracies_under_severe_time_pressure,
    sum(player_game_info.num_mistakes_under_time_severe_pressure) as num_mistakes_under_time_severe_pressure,
    sum(player_game_info.num_blunders_under_time_severe_pressure) as num_blunders_under_time_severe_pressure,
from player_game_info
inner join game_outline on player_game_info.game_id = game_outline.game_id
inner join surrogate_game_id_map on player_game_info.game_id = surrogate_game_id_map.game_id
inner join game_headers on surrogate_game_id_map.surrogate_game_id = game_headers.surrogate_game_id
group by 1,2,3,4,5,6