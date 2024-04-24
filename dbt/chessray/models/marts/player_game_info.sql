with game_players as (
    select * from {{ ref('stg_lichess__game_players') }}
),

game_outline as (
    select * from {{ ref('stg_lichess__rounds_detail') }}
),

game_detail as (
    select 
        surrogate_game_id,
        is_white_move as is_white,
        max(move_number) as num_moves,
        count(*)/sum(1/move_accuracy) as player_accuracy,
        sum(case when is_capture then 1 else 0 end) as num_captures,
        sum(case when is_check then 1 else 0 end) as num_checks_given,
        max(is_checkmate) as ends_in_checkmate,
        sum(case when nag = 6 then 1 else 0 end) as num_inaccuracies,
        sum(case when nag = 2 then 1 else 0 end) as num_mistakes,
        sum(case when nag = 4 then 1 else 0 end) as num_blunders,
        sum(case 
                when nag = 2 or nag = 4 or nag = 6
                then 1 else 0
            end
        ) as num_poor_moves,
    from {{ ref('stg_lichess__game_moves') }}
    where is_finished
    group by 1,2
),

game_headers as (
    select * from {{ ref('stg_lichess__game_headers') }}
),

rounds_outline as (
    select * from {{ ref('stg_lichess__rounds_outline') }}
),

initial_player_game_info as (
    select 
        game_players.player_name,
        game_players.game_id,
        game_outline.round_id,
        rounds_outline.tournament_id,
        case
            when is_draw then 0.5
            when (game_players.is_white and game_outline.is_white_victory)
            or (not game_players.is_white and game_outline.is_black_victory) then 1
            else 0
        end as num_points,
        game_players.color,
        game_players.is_white,
        coalesce(
            game_headers_white.surrogate_game_id, 
            game_headers_black.surrogate_game_id
        ) as surrogate_game_id,
        coalesce(
            game_headers_white.chess_variant, 
            game_headers_black.chess_variant
        ) as chess_variant,
        coalesce(
            game_headers_white.opening_general, 
            game_headers_black.opening_general
        ) as opening_general,
    from game_players
    inner join game_outline on game_players.game_id = game_outline.game_id
    inner join rounds_outline on game_outline.round_id = rounds_outline.round_id
    left join game_headers as game_headers_white on rounds_outline.round_id = game_headers_white.round_id
        and game_players.player_name = game_headers_white.white_player
    left join game_headers as game_headers_black on rounds_outline.round_id = game_headers_black.round_id
        and game_players.player_name = game_headers_black.black_player 
)

select 
initial_player_game_info.* exclude(surrogate_game_id, is_white),
game_detail.num_moves,
game_detail.player_accuracy,
game_detail.num_captures,
game_detail.num_checks_given,
game_detail.ends_in_checkmate,
game_detail.num_inaccuracies,
game_detail.num_mistakes,
game_detail.num_blunders,
game_detail.num_poor_moves,
from initial_player_game_info
inner join game_detail on initial_player_game_info.surrogate_game_id = game_detail.surrogate_game_id
    and initial_player_game_info.is_white = game_detail.is_white


    

