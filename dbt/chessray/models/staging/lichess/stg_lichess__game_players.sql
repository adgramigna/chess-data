select 
    surrogate_game_player_id,
    {{ clean_player_name("name") }} as player_name,
    game_id,
    color,
    is_white,
    rating,
    federation,
    title,
    clock
from {{ source('lichess', 'game_players') }}  