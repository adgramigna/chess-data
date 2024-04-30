select
    player_name,
    game_id,
    is_white_move as is_white,
    is_endgame,
    time_pressure_category,
    count(surrogate_move_id) as player_moves,
    sum(case when is_check then 1 else 0 end) as num_checks_given,
    sum(case when is_capture then 1 else 0 end) as num_captures,
    sum(time_spent_on_move) as time_spent_on_moves,
    sum(case when is_lost_winning_advantage then 1 else 0 end) as num_times_losing_winning_advantage,
    sum(case when is_given_away_winning_advantage then 1 else 0 end) as num_times_given_away_winning_advantage,
    sum(case when nag = 6 then 1 else 0 end) as num_inaccuracies,
    sum(case when nag = 2 then 1 else 0 end) as num_mistakes,
    sum(case when nag = 4 then 1 else 0 end) as num_blunders,
    sum(case when is_poor_move then 1 else 0 end) as num_poor_moves,
    max(has_winning_advantage) as has_winning_advantage,
from {{ ref('int_player_moves_with_ids') }}
group by 1,2,3,4,5