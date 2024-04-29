select
    game_id,
    tournament_id,
    player_name,
    count(*)/sum(1/move_accuracy) as accuracy
from {{ ref('int_player_moves_with_ids') }}
group by 1,2,3