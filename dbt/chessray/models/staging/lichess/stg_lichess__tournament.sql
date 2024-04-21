select 
    tournament_id,
    name as tournament_name,
    slug as slug,
    to_timestamp(created_at) as tournament_created_at,
    tier,
    url as tournament_url,
    image as tournament_image,
    leaderboard as has_leaderboard
from {{ source('lichess', 'tournament') }}
