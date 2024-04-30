with player_moves_agg as (
    select
        player_name,
        game_id,
        is_white,
        sum(player_moves) as player_moves,
        sum(num_checks_given) as num_checks_given,
        sum(num_captures) as num_captures,
        sum(time_spent_on_moves) as time_spent_on_moves,
        sum(num_times_losing_winning_advantage) as num_times_losing_winning_advantage,
        sum(num_times_given_away_winning_advantage) as num_times_given_away_winning_advantage,
        sum(num_inaccuracies) as num_inaccuracies,
        sum(num_mistakes) as num_mistakes,
        sum(num_blunders) as num_blunders,
        sum(num_poor_moves) as num_poor_moves,
        max(case when is_endgame then has_winning_advantage end) as had_endgame_winning_advantange,
        max(has_winning_advantage) as had_winning_advantange,
    from {{ ref('int_player_moves_agg') }}
    group by 1,2,3
),

player_moves_agg_swap_winning_advantage as (
    select 
        player_name,
        game_id,
        case 
            when is_white 
                then lag(num_times_given_away_winning_advantage) over(partition by game_id order by is_white)
            when not is_white 
                then lead(num_times_given_away_winning_advantage) over(partition by game_id order by is_white)
        end as num_times_gaining_winning_advantage, 
    from player_moves_agg
)

select 
    player_moves_agg.*,
    player_moves_agg_swap_winning_advantage.num_times_gaining_winning_advantage,
from player_moves_agg
inner join player_moves_agg_swap_winning_advantage on ids_map.game_id = player_moves_agg_swap_winning_advantage.game_id
    and game_players.player_name = player_moves_agg_swap_winning_advantage.player_name

