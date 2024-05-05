with add_color_with_winning_advantage as (
    select *,
    case
        when is_checkmate_countdown and engine_evaluation_score > 0 then 'white'
        when is_checkmate_countdown and engine_evaluation_score < 0 then 'black'
        when engine_evaluation_score > {{ var('winning_advantage_eval') }} then 'white'
        when engine_evaluation_score < -1 * {{ var('winning_advantage_eval') }} then 'black'
        else 'neutral'
    end as color_with_winning_advantage
    from {{ source('lichess', 'game_moves') }}
),

moves_augmented as (
    select *, 
        case 
            when not is_checkmate_countdown then 100 / (1 + exp(-0.00368208 * engine_evaluation_score * 100)) 
            else 100 / (1 + exp(-0.00368208 * (1000 - engine_evaluation_score)))
        end as white_win_percentage,
        lag(color_with_winning_advantage) over(partition by surrogate_game_id order by row_number) as previous_color_with_winning_advantage,
        lag(clock_time) over(partition by surrogate_game_id, is_white_move order by row_number) - clock_time as time_spent_on_move,
        nag = 2 or nag = 4 or nag = 6 as is_poor_move,
        lower(split_part(fen,' ',1)) as fen_lower,
        replace(replace(replace(replace(lower(split_part(fen,' ',1)), 'b', ''),'n', ''), 'q', ''), 'r', '') as fen_no_majors
    from add_color_with_winning_advantage
)

select 
    surrogate_move_id,
    surrogate_game_id,
    row_number as move_row_number,
    move_number,
    starting_square,
    san,
    san = 'e4' and move_number = 1 as is_e4_game,
    san = 'd4' and move_number = 1 as is_d4_game,
    case 
        when left(san, 1) = 'K' then 'king'
        when left(san, 1) = 'R' then 'rook'
        when left(san, 1) = 'B' then 'bishop'
        when left(san, 1) = 'N' then 'knight'
        when left(san, 1) = 'Q' then 'queen'
        else 'pawn'
    end as piece_moved,
    right(san, 1) = '+' or right(san, 1) = '#' as is_check,
    right(san, 1) = '#' as is_checkmate,
    position('x' in san) > 0 as is_capture,
    case 
        when is_white_move then least(103.1668 * exp(-0.04354 * (lag(white_win_percentage) 
            over(partition by surrogate_game_id order by row_number) - white_win_percentage)) - 3.1669, 100) 
        when not is_white_move then least(103.1668 * exp(-0.04354 * (lag((100 - white_win_percentage)) 
            over(partition by surrogate_game_id order by row_number) - (100 - white_win_percentage))) - 3.1669, 100) 
    end as move_accuracy,
    time_spent_on_move,
    white_win_percentage,
    case 
        when clock_time < 60 then 'severe time pressure'
        when clock_time < 300 then 'time pressure'
        else 'no time pressure'
    end as time_pressure_category,
    length(fen_lower) - length(fen_no_majors) <= 6 as is_endgame,
    engine_evaluation_score,
    case 
        when not is_checkmate_countdown then engine_evaluation_score
        when engine_evaluation_score < 0 then -10 + (engine_evaluation_score / 100)
        when engine_evaluation_score > 0 then 10 + (engine_evaluation_score / 100)
    end as massaged_engine_evaluation_score,
    color_with_winning_advantage,
    (previous_color_with_winning_advantage != color_with_winning_advantage 
        and (color_with_winning_advantage = 'white' and not is_white_move
        or color_with_winning_advantage = 'black' and is_white_move)) 
        and (is_poor_move) 
        as is_given_away_winning_advantage,
    ((previous_color_with_winning_advantage = 'white' and color_with_winning_advantage != 'white' and is_white_move) 
        or (previous_color_with_winning_advantage = 'black' and color_with_winning_advantage != 'black' and not is_white_move))
     and (is_poor_move)
     as is_lost_winning_advantage,
    is_checkmate_countdown,
    is_white_move,
    nag,
    is_poor_move,
    comment,
    fen
from moves_augmented
