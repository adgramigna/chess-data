with player_game_accuracy as (
    select * from {{ ref('int_player_game_accuracy') }}
),

game_outline as (
    select * from {{ ref('stg_lichess__rounds_detail') }}
),

game_headers as (
    select * from {{ ref('stg_lichess__game_headers') }}
),

ids_map as (
    select * from {{ ref('int_ids_map') }}
),

game_moves_agg as (
    select 
        game_id,
        sum(player_moves) as game_moves
    from {{ ref('player_moves_agg') }}
    group by 1
)
 
select
    ids_map.game_id,
    ids_map.round_id,
    ids_map.tournament_id,
    game_outline.game_status,
    game_headers.chess_variant,
    game_headers.opening_general,
    player_game_accuracy.accuracy,
    game_moves_agg.game_moves
from ids_map
inner join game_outline on ids_map.game_id = game_outline.game_id
inner join game_headers on ids_map.surrogate_game_id = game_headers.surrogate_game_id
inner join game_moves_agg on ids_map.game_id = game_moves_agg.game_id
inner join player_game_accuracy on ids_map.game_id = player_game_accuracy.game_id