select
    player_name,
    game_id,
    is_endgame,
    time_pressure_category,
    count(surrogate_move_id) as player_moves,
    sum(case when is_check then 1 else 0 end) as num_checks_given,
    sum(case when is_capture then 1 else 0) as num_captures,
    sum(time_spent_on_move) as time_spent_on_moves,
    sum(is_lost_winning_advantage) as num_times_losing_winning_advantage,
    sum(case when nag = 6 then 1 else 0 end) as num_inaccuracies,
    sum(case when nag = 2 then 1 else 0 end) as num_mistakes,
    sum(case when nag = 4 then 1 else 0 end) as num_blunders,
    sum(case when nag = 2 or nag = 4 or nag = 6 then 1 else 0 end) as num_poor_moves,
    {# is_white_winning_advantage,
    is_black_winning_advantage,
    (is_white_winning_advantage and is_white_move) or
    (is_black_winning_advantage and not is_white_move) as is_gained_winning_advantage, #}
from {{ ref('int_player_moves_with_ids') }}
group by 1,2,3,4