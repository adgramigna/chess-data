select 
    game_id,
    round_id,
    fen,
    last_move,
    status as game_status,
    case 
        when status = '*' then true
        else false
    end as is_finished,
    case 
        when status = '1-0' then true
        when status = '*' then null
        else false
    end as is_white_victory,
    case 
        when status = '0-1' then true
        when status = '*' then null
        else false
    end as is_black_victory,
    case 
        when status = '½-½' then true
        when status = '*' then null
        else false
    end as is_draw,
    cast(think_time as integer) / 100 as think_time_seconds
from {{ source('lichess', 'rounds_detail') }}
