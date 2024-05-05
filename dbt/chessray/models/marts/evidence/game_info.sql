with player_game_info as (
    select
        game_id,
        sum(player_moves) as total_half_moves,
        max(player_moves) as total_moves,
        sum(num_checks_given) as total_checks_given,
        sum(num_captures) as total_captures,
        sum(num_inaccuracies) as total_inaccuracies,
        sum(num_mistakes) as total_mistakes,
        sum(num_blunders) as total_blunders,
        sum(num_poor_moves) as total_poor_moves,
    from {{ ref('player_game_info') }}
    group by 1
),

game_outline as (
    select * from {{ ref('stg_lichess__rounds_detail') }}
),

game_headers as (
    select * from {{ ref('stg_lichess__game_headers') }}
),

first_game_move as (
    select * from {{ ref('int_game_first_move') }}
),

ids_map as (
    select
        game_id,
        surrogate_game_id,
        round_id,
        tournament_id
    from {{ ref('int_ids_map') }}
    group by all
),

white_and_black_players as (
    select * from {{ ref('int_players_to_white_and_black') }}
)
 
select
    ids_map.game_id,
    ids_map.round_id,
    ids_map.tournament_id,
    game_outline.game_status,
    game_headers.chess_variant,
    game_headers.opening_general,
    white_and_black_players.white_player,
    white_and_black_players.black_player,
    white_and_black_players.white_player_colloquial,
    white_and_black_players.black_player_colloquial,
    first_game_move.first_move,
    player_game_info.* exclude(game_id)
from ids_map
inner join game_outline on ids_map.game_id = game_outline.game_id
inner join game_headers on ids_map.surrogate_game_id = game_headers.surrogate_game_id
inner join white_and_black_players on ids_map.game_id = white_and_black_players.game_id
inner join player_game_info on ids_map.game_id = player_game_info.game_id
inner join first_game_move on ids_map.surrogate_game_id = first_game_move.surrogate_game_id