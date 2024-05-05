with add_winning_advantage as (
      select *,
        num_times_given_away_winning_advantage > 0 as had_losing_position,
        num_times_given_away_winning_advantage > 0 and num_points != 0 as is_saved_losing_position,
        num_times_gaining_winning_advantage > 0 as had_winning_advantage,
        num_times_gaining_winning_advantage > 0 and num_points = 1 as is_converted_winning_advantage,
    from player_game_info
)

select 
    tournament_id,
    colloquial_name,
    sum(case when had_winning_advantage then 1 else 0 end) as times_with_winning_advantage,
    sum(case when num_points = 1 then 1 else 0 end) as wins,
    sum(case when is_converted_winning_advantage then 1 else 0 end) as winning_advantages_converted,
    sum(case when is_saved_losing_position then 1 else 0 end) as losing_positions_saved,
    sum(case when had_losing_position then 1 else 0 end) as times_with_losing_position,
from add_winning_advantage
where tournament_id = 'wEuVhT9c'
group by 1,2