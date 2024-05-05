# Player Breakdown

## Time Pressure Performance

```sql time_pressure_options
select distinct
    time_pressure_category
from player_moves_agg
```

```sql endgame_options
select distinct
    case when is_endgame = true then 'True' else 'False' end as is_endgame_string
from player_moves_agg
```

<Dropdown
    name=category
    title="Time Pressure Category"
    data={time_pressure_options}
    value=time_pressure_category
>
    <DropdownOption valueLabel="All" value="%" />
</Dropdown>

<Dropdown
    name=endgame
    title="Is Endgame"
    data={endgame_options}
    value=is_endgame_string
>
    <DropdownOption valueLabel="All" value="%" />
</Dropdown>

```sql poor_moves_breakdown
with add_is_endgame_string as (
    select *, case when is_endgame = true then 'True' else 'False' end as is_endgame_string 
    from
    player_moves_agg
),


player_moves_agg_cleaned as (
    select 
        colloquial_name,
        case 
            when time_pressure_category = '${inputs.category.value}' then time_pressure_category
            else 'All'
        end as time_pressure_category,
        case 
            when is_endgame_string = '${inputs.endgame.value}' then is_endgame_string
            else 'All'
        end as is_endgame_string,
        case 
            when nag = 4 then 'Blunder'
            when nag = 2 then 'Mistake'
            when nag = 6 then 'Inaccuracy'
            else 'Not Poor Move'
        end as move_type,
        sum(player_moves) as player_moves,
    from add_is_endgame_string
    where nag != 0
    and time_pressure_category like '${inputs.category.value}' 
    and is_endgame_string like '${inputs.endgame.value}' 
    group by 1,2,3,4
)

select *
from player_moves_agg_cleaned
```

<BarChart
    data={poor_moves_breakdown}
    x=colloquial_name
    y=player_moves
    series=move_type 
    type=grouped
    colorPalette={['#177BB6','#B27A02','#D62929']}
    title="Poor Moves by Game Sitauation"
/>

Nakamura played amazingly in endgames, only one innaccuracy all tournament! With no time pressure, Gukesh played the most sharp chess not having a single mistake or blunder until he reached time pressure.

```sql poor_moves_time_pressure
with poor_moves_agg as (
    select 
        colloquial_name,
        time_pressure_category,
        sum(case when nag != 0 then player_moves end) as poor_moves,
        sum(player_moves) as player_moves,
    from player_moves_agg
    group by 1,2
)

select *,
coalesce(poor_moves / player_moves,0) as poor_move_pct,
from poor_moves_agg
```

<BarChart 
    data={poor_moves_time_pressure} 
    x=colloquial_name
    y=poor_move_pct
    series=time_pressure_category
    type=grouped
    title="Poor Move % by Time Pressure Category"
/>

If there was a weakness for Gukesh this tournament, it was his struggles in severe time pressure. His 10x increase in poor moves in severe time pressure is well ahead of any other candidate. For Alireza Firouzja, time pressure seemed to affect him less than the field, as his poor move rate did not drastically jump with each tier. Nepo and Nakamura, as they are known for, managed to avoid clock trouble for much of the tournament.

```sql overall_poor_moves
with poor_moves_agg as (
    select 
        'Overall' as type,
        time_pressure_category,
        sum(case when nag != 0 then player_moves end) as poor_moves,
        sum(player_moves) as player_moves,
    from player_moves_agg
    group by 1,2
),

add_pct as (
    select *,
    coalesce(poor_moves / player_moves,0) as poor_move_pct,
    from poor_moves_agg
),

overall_view as (
    select
        type,
        max(case when time_pressure_category = 'no time pressure' then poor_move_pct end) as poor_move_pct_no_tp,
        max(case when time_pressure_category = 'time pressure' then poor_move_pct end) as poor_move_pct_tp,
        max(case when time_pressure_category = 'severe time pressure' then poor_move_pct end) as poor_move_pct_severe_tp
    from add_pct
    group by 1 
)

select *, 
    poor_move_pct_tp / poor_move_pct_no_tp - 1 as pct_change_2,
    poor_move_pct_severe_tp / poor_move_pct_tp - 1 as pct_change_1,
from overall_view
```

#### Overall Poor Moves in Time Pressure

<BigValue 
  data={overall_poor_moves}
  value=poor_move_pct_no_tp
  title="Poor Moves No Time Pressure"
  fmt=#,##0.0%
/>

<BigValue 
  data={overall_poor_moves}
  value=poor_move_pct_tp
  title="Poor Moves Time Pressure"
  fmt=#,##0.0%
  comparison=pct_change_1
  downIsGood=true
  comparisonTitle="from prior category"
  comparisonFmt=#,##0%
/>

<BigValue 
  data={overall_poor_moves}
  value=poor_move_pct_severe_tp
  title="Poor Moves Severe Time Pressure"
  fmt=#,##0.0%
  comparison=pct_change_2
  downIsGood=true
  comparisonTitle="from prior category"
  comparisonFmt=#,##0%
/>

Poor moves increase in likelihood by 2-3x with each jump in time pressure category

## Winning and Losing Positions

```sql winning_and_losing_positions
select * from lichess_data.winning_and_losing_advantage
```

<BarChart
  data={winning_and_losing_positions}
  x=colloquial_name
  y=times_with_winning_advantage
  y2=wins
  y2AxisLabels=false
  yAxisTitle=false
  y2AxisTitle=false
  colorPalette={['cornflowerblue', 'wheat']}
  title="Winning Positions Converted"
/>

Vidit is a bit of a surprise to see with the most winning positions in the tournament. He was unable to convert twice, the most of any candidate. Gukesh converted all five of his winning positions, a crucial factor in his tournament victory.

<BarChart
  data={winning_and_losing_positions}
  x=colloquial_name
  y=times_with_losing_position
  y2=losing_positions_saved
  y2AxisLabels=false
  yAxisTitle=false
  y2AxisTitle=false
  colorPalette={['cornflowerblue', 'wheat']}
  y2Min=0
  y2Max=8
  title="Losing Positions Saved"
/>

Nepo was praised for his defending all tournament, he miraculously worked his way out of 3 losing positions, while the remaining candidates combined only did this once.
