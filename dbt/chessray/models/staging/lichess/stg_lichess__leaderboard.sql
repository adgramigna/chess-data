select
    surrogate_leaderboard_id,
    fide_id,
    tournament_id,
    name as player_name,
    score,
    number_of_rounds_played,
    rating,
    title as player_title,
    federation as player_federation
from {{ source('lichess', 'leaderboard') }}

  