select 
    round_id,
    tournament_id,
    name as round_name,
    slug,
    to_timestamp(created_at) as created_at,
    to_timestamp(starts_at) as starts_at,
    url as round_url,
    finished as is_finished
from {{ source('lichess', 'rounds_outline') }}
