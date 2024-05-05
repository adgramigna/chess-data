with game_headers as (
    select * from {{ ref('stg_lichess__game_headers') }}
),

game_outline as (
    select * from {{ ref('stg_lichess__rounds_detail') }}
),

game_players as (
    select * from {{ ref('stg_lichess__game_players') }}
),

rounds_outline as (
    select * from {{ ref('stg_lichess__rounds_outline') }}
)

select
    md5(game_players.player_name || '_' || game_players.game_id) as id,
    game_players.game_id,
    game_players.player_name,
    coalesce(
        game_headers_white.surrogate_game_id, 
        game_headers_black.surrogate_game_id
    ) as surrogate_game_id,
    rounds_outline.round_id,
    rounds_outline.tournament_id,
    rounds_outline.round_number,
    game_players.color,
    game_players.is_white,
    game_players.colloquial_name,
from game_players
inner join game_outline on game_players.game_id = game_outline.game_id
inner join rounds_outline on game_outline.round_id = rounds_outline.round_id
left join game_headers as game_headers_white on rounds_outline.round_id = game_headers_white.round_id
    and game_players.player_name = game_headers_white.white_player
left join game_headers as game_headers_black on rounds_outline.round_id = game_headers_black.round_id
    and game_players.player_name = game_headers_black.black_player