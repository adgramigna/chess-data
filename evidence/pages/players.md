# Player Breakdown

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

```sql poor_moves_2
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

```sql poor_moves_3
with poor_moves_agg as (
    select 
        'Overall' as type,
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
    data={poor_moves_breakdown}
    x=colloquial_name
    y=player_moves
    series=move_type 
    type=grouped
    colorPalette={['#177BB6','#B27A02','#D62929']}
    title="Poor Moves by Game Sitauation"
/>

<BarChart 
    data={poor_moves_2} 
    x=colloquial_name
    y=poor_move_pct
    series=time_pressure_category
    type=grouped
/>

<BarChart 
    data={poor_moves_3} 
    x=type
    y=poor_move_pct
    yFmt=#,##0.0%
    series=time_pressure_category
    type=grouped
/>


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
/>

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
/>



