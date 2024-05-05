--can be used to remove game headers
select  
    game_id,
    max(case when is_white then player_name end) as white_player,
    max(case when not is_white then player_name end) as black_player,
    max(case when is_white then colloquial_name end) as white_player_colloquial,
    max(case when not is_white then colloquial_name end) as black_player_colloquial
from {{ ref('stg_lichess__game_players') }}
group by 1
