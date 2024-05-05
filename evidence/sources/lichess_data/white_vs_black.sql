select 
    tournament_id,
    is_white, 
    sum(num_points) total_points,
    sum(case when num_points = 1 then 1 else 0 end) as num_wins, 
    sum(case when num_points = 0.5 then 1 else 0 end) as num_draws, 
    sum(case when num_points = 0 then 1 else 0 end) as num_losses, 
from player_game_info
where tournament_id = 'wEuVhT9c'
group by 1,2