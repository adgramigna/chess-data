select 
    opening_general, 
    count(*) as total_games
from src_game_info
where tournament_id = 'wEuVhT9c'
group by 1
order by 2 desc