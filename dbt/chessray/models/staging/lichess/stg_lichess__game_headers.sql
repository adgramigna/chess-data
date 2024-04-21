select 
    surrogate_game_id,
    round_id,
    event as chess_event,
    site as event_location,
    date as event_date_local,
    round as event_round,
    white as white_player,
    black as black_player,
    result,
    variant as chess_variant,
    opening,
    annotator
from {{ source('lichess', 'game_headers') }}
