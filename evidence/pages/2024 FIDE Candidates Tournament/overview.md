---
title: "Overview"
sidebar_position: 1
---

```sql leaderboard
select 
    player_name,
    sum(num_points) as points,
    sum(case when num_points = 1 then 1 else 0 end) as wins, 
    sum(case when num_points = 0.5 then 1 else 0 end) as draws, 
    sum(case when num_points = 0 then 1 else 0 end) as losses, 
from lichess_data.src_player_game_info
group by 1
order by 2 desc, sum(num_blunders)
```
## Results
<DataTable data={leaderboard}>
	<Column id=player_name />
	<Column id=points fmt=#,##0.0 />
  <Column id=wins/>
	<Column id=draws/>
  <Column id=losses/>
</DataTable>

```sql standings_over_time
  select
    round_number,
    colloquial_name,
    sum(num_points) over (partition by colloquial_name order by round_number asc rows between unbounded preceding and current row) as current_points,
  from src_player_game_info
```

<LineChart
  data={standings_over_time}
  x=round_number
  y=current_points
  series=colloquial_name
  step=true
  stepPosition=start
  colorPalette={['#FFCDCB','#FFD166','#06D6A0', '#118AB2', '#EF476F', '#000065', '#8338EC', '#FF9F1C']}
  title="Standings by Round"
/>

```sql accuracy
    select 
        colloquial_name, 
        tournament_id, 
        count(distinct game_id) as total_games,
        avg(accuracy) / 100 as accuracy
    from src_player_game_info
    group by 1,2
    order by 2, 4 desc
```

<BarChart
  data={accuracy}
  x=colloquial_name
  y=accuracy
  yMin=.9
  yFmt=#,##0.0%
  title="Avg Accuracy by Player"
  colorPalette={['#80B64B']}
/>

Despite having no losses and the highest accuracy, Nepo could not top Gukesh. 


```sql all_game_info
  select * from lichess_data.src_game_info
```

## Poor Moves by Player

<Heatmap 
    data={all_game_info} 
    x=white_player_colloquial 
    y=black_player_colloquial
    value=total_poor_moves
    subtitle="White Player Horizontal Black Player Vertical"
    xLabelRotation=-45
    xSort=white_player
    ySort=black_player
    colorPalette={['#fde725', '#a0da39', '#4ac16d', '#1fa187', '#277f8e', '#365c8d', '#46327e', '#440154']}
    mobileValueLabels=true
/>

Gukesh vs Abasov was the biggest blunderfest of the tournament, with the infamous Fabi/Nepo round 14 game as a close second. Another key insight from this shows Nepo was unable to capitalize in games with the white pieces. Despite not losing a single game, in games where Nepo needed to push for a win, either his opponents defended incredibly well, or he was unable to bring them into complicated positions. 


```sql game_stats
  select 
    tournament_id,
    avg(total_moves) as avg_total_moves,
    avg(total_poor_moves) as avg_total_poor_moves,
    avg(total_captures) as avg_total_captures,
  from lichess_data.src_game_info
  group by 1
```

## Summary Statistics per game

<BigValue 
  data={game_stats}
  value=avg_total_moves
  title="Average Total Moves"
  fmt=#,##0.0
/>

<BigValue 
  data={game_stats}
  value=avg_total_poor_moves
  title="Average Total Poor Moves"
  fmt=#,##0.0
/>

<BigValue 
  data={game_stats}
  value=avg_total_captures
  title="Average Total Captures"
  fmt=#,##0.0
/>
