select 
    surrogate_game_id,
    is_white_move as is_white,
    max(move_number) as num_moves,
    count(case when time_pressure_category = 'severe time pressure' then surrogate_move_id end) as num_moves_in_severe_time_pressure,
    count(case when time_pressure_category = 'time pressure' then surrogate_move_id end) as num_moves_in_time_pressure,
    count(case when time_pressure_category = 'no time pressure' then surrogate_move_id end) as num_moves_in_no_time_pressure,
    count(*)/sum(1/move_accuracy) as player_accuracy,
    sum(case when is_capture then 1 else 0 end) as num_captures,
    sum(case when is_check then 1 else 0 end) as num_checks_given,
    max(is_checkmate) as ends_in_checkmate,
    sum(case when nag = 6 then 1 else 0 end) as num_inaccuracies,
    sum(case when nag = 2 then 1 else 0 end) as num_mistakes,
    sum(case when nag = 4 then 1 else 0 end) as num_blunders,
    sum(case 
            when nag = 2 or nag = 4 or nag = 6
            then 1 else 0
        end
    ) as num_poor_moves,
    sum(case when nag = 6 and time_pressure_category = 'time pressure' then 1 else 0 end) as num_inaccuracies_under_time_pressure,
    sum(case when nag = 2 and time_pressure_category = 'time pressure' then 1 else 0 end) as num_mistakes_under_time_pressure,
    sum(case when nag = 4 and time_pressure_category = 'time pressure' then 1 else 0 end) as num_blunders_under_time_pressure,
    sum(case when nag = 6 and time_pressure_category = 'severe time pressure' then 1 else 0 end) as num_inaccuracies_under_severe_time_pressure,
    sum(case when nag = 2 and time_pressure_category = 'severe time pressure' then 1 else 0 end) as num_mistakes_under_time_severe_pressure,
    sum(case when nag = 4 and time_pressure_category = 'severe time pressure' then 1 else 0 end) as num_blunders_under_time_severe_pressure,
from {{ ref('stg_lichess__game_moves') }}
group by 1,2