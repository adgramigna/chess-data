select 
    surrogate_game_id,
    round_id,
    event as chess_event,
    site as event_location,
    date as event_date_local,
    round as event_round,
    {{ clean_player_name("white") }} as white_player,
    {{ clean_player_name("black") }} as black_player,
    result,
    variant as chess_variant,
    opening,
    split_part(opening, ':', 1) as opening_general,
    annotator
from {{ source('lichess', 'game_headers') }}
