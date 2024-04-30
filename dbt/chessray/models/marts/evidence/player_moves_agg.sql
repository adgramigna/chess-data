select *
from {{ ref('int_player_moves_agg') }}