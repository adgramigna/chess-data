select 
    
from {{ ref('game_moves') }}
group by 1,2,3,4,5