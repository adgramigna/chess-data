select
    tournament_id,
    player_name,
    avg(player_game_accuracy) as player_tournament_accuracy
from {{ ref('int_player_game_accuracy') }}
group by 1,2