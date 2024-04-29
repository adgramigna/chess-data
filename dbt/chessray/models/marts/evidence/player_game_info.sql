with game_players as (
    select * from {{ ref('stg_lichess__game_players') }}
),

player_moves_agg as (
    select
        player_name,
        game_id,
        sum(player_moves) as player_moves,
        sum(num_checks_given) as num_checks_given,
        sum(num_captures) as num_captures,
        sum(time_spent_on_moves) as time_spent_on_moves,
        sum(num_times_losing_winning_advantage) as num_times_losing_winning_advantage,
        sum(num_inaccuracies) as num_inaccuracies,
        sum(num_mistakes) as num_mistakes,
        sum(num_blunders) as num_blunders,
        sum(num_poor_moves) as num_poor_moves,
    from {{ ref('player_moves_agg') }}
    group by 1,2
),

game_outline as (
    select * from {{ ref('stg_lichess__rounds_detail') }}
),

ids_map as (
    select * from {{ ref('int_ids_map') }}
),

select 
    md5(game_players.player_name || '_' || game_players.game_id) as id,
    game_players.player_name,
    game_players.colloquial_name,
    game_players.game_id,
    ids_map.round_id,
    ids_map.tournament_id,
    case
        when is_draw then 0.5
        when (game_players.is_white and game_outline.is_white_victory)
        or (not game_players.is_white and game_outline.is_black_victory) then 1
        else 0
    end as num_points,
    game_players.color,
    game_players.is_white,
    player_moves_agg.* exclude(player_name, game_id)
from game_players
inner join game_outline on game_players.game_id = game_outline.game_id
inner join ids_map on game_players.game_id = ids_map.game_id
inner join player_moves_agg on ids_map.game_id = player_moves_agg.game_id
    and game_players.player_name = ids_map.player_name