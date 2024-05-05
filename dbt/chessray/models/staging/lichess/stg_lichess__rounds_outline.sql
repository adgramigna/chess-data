select 
    round_id,
    tournament_id,
    name as round_name,
    slug,
    epoch_ms(created_at) as created_at,
    epoch_ms(starts_at) as starts_at,
    row_number() over(partition by tournament_id order by starts_at) as round_number,
    url as round_url,
    finished as is_finished
from {{ source('lichess', 'rounds_outline') }}
where finished
