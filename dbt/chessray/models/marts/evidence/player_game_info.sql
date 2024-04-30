with game_players as (
    select * from {{ ref('stg_lichess__game_players') }}
),

player_moves_agg as (
    select * from {{ ref('int_player_game_swap_winning_advantage') }}
),

player_game_points as (
    select * from {{ ref('int_player_game_points') }}
),

ids_map as (
    select * from {{ ref('int_ids_map') }}
),

player_game_accuracy as (
    select * from {{ ref('int_player_game_accuracy') }}
)

select 
    md5(game_players.player_name || '_' || game_players.game_id) as id,
    game_players.player_name,
    game_players.colloquial_name,
    game_players.game_id,
    ids_map.round_id,
    ids_map.tournament_id,
    player_game_points.num_points,
    game_players.color,
    game_players.is_white,
    player_game_accuracy.accuracy,
    player_moves_agg.* exclude(player_name, game_id, is_white, num_times_gaining_winning_advantage),
    --if no explicit times gaining winning advantage and you win, it must have happened once
    case
        when num_points = 1 and num_times_gaining_winning_advantage <= num_times_losing_winning_advantage 
        then num_times_losing_winning_advantage + 1
        when num_times_gaining_winning_advantage < num_times_losing_winning_advantage
        then num_times_losing_winning_advantage
        else num_times_gaining_winning_advantage
    end as num_times_gaining_winning_advantage
from game_players
inner join ids_map on game_players.game_id = ids_map.game_id
    and game_players.player_name = ids_map.player_name
inner join player_game_points on game_players.game_id = player_game_points.game_id
    and game_players.player_name = player_game_points.player_name
inner join player_moves_agg on ids_map.game_id = player_moves_agg.game_id
    and game_players.player_name = player_moves_agg.player_name
inner join player_game_accuracy on ids_map.game_id = player_game_accuracy.game_id
    and game_players.player_name = player_game_accuracy.player_name