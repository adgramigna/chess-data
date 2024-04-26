with game_players_augmented as (
    select 
        * exclude(name),
        {{ clean_player_name("name") }} as player_name,
    from {{ source('lichess', 'game_players') }}

),

game_players_further_augmented as (
    select
        *,
        split_part(player_name, ', ', 1) as last_name,
        split_part(player_name, ', ', 2) as first_name,
    from game_players_augmented

)

select 
    surrogate_game_player_id,
    player_name,
    case 
        when left(last_name, 4) = 'Nepo' then 'Nepo'
        when left(first_name, 5) = 'Pragg' then 'Pragg'
        when len(last_name) = 1 then first_name
        else last_name
    end as colloquial_name,
    game_id,
    color,
    is_white,
    rating,
    federation,
    title
from game_players_further_augmented
