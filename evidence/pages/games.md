# Game Breakdown

```sql player_options
    select distinct colloquial_name from player_game_info
```

<Dropdown
    name=white_player_name
    title="White Player"
    data={player_options}  
    value=colloquial_name
    defaultValue="Firouzja"
>
</Dropdown>

<Dropdown
    name=black_player_name
    title="Black Player"
    data={player_options}  
    value=colloquial_name
    defaultValue="Pragg"
>
</Dropdown>

```sql game_moves_formatted
with unioned_moves as (
    select 
        game_id,
        white_player_colloquial,
        black_player_colloquial,
        move_row_number, 
        move_number,
        massaged_engine_evaluation_score, 
        greatest(massaged_engine_evaluation_score,0) as graph_score,
        massaged_engine_evaluation_score >= 0 as is_kept,
        'White' as move_color, 
    from game_moves
    where is_white_move
    union all
    select
        game_id, 
        white_player_colloquial,
        black_player_colloquial,
        move_row_number, 
        move_number,
        massaged_engine_evaluation_score,
        least(massaged_engine_evaluation_score,0) as graph_score,
        massaged_engine_evaluation_score <= 0 as is_kept,
        'Black' as move_color,
    from lichess_data.game_moves
    where not is_white_move
)

select * from unioned_moves
where white_player_colloquial = '${inputs.white_player_name.value}'
and black_player_colloquial = '${inputs.black_player_name.value}'
and is_kept
order by move_number, move_color desc
```

<AreaChart
    data={game_moves_formatted}
    x=move_number
    y=graph_score
    yFmt=#,##0.00
    series=move_color
    colorPalette={['#f4ebe0', '#121212']}
    lineColor='#D85001'
    legend=false
    title="Engine Evaluation Throughout the Game">
    <ReferenceLine y=1.5 label="White Winning Advantage" hideValue=true labelPosition=aboveStart/>
    <ReferenceLine y=-1.5 label="Black Winning Advantage" hideValue=true labelPosition=aboveStart/>
</AreaChart>

```sql game_result
select 
    game_info.game_status, game_info.white_player_colloquial, game_info.black_player_colloquial 
    from lichess_data.game_info
    inner join ${game_moves_formatted} as gmf on game_info.game_id = gmf.game_id
    group by all
```

{#if game_result[0].game_status == '½-½'}
**½-½**
<Value data={game_result} column=white_player_colloquial/> vs. <Value data={game_result} column=black_player_colloquial/> resulted in a draw.


{:else if game_result[0].game_status == '1-0'}
**1-0**
<Value data={game_result} column=white_player_colloquial/> defeated <Value data={game_result} column=black_player_colloquial/> with the white pieces.

{:else if game_result[0].game_status == '0-1'}
**0-1**
<Value data={game_result} column=black_player_colloquial/> defeated <Value data={game_result} column=white_player_colloquial/> with the black pieces.

{:else}

    Loading...

{/if}



{#if game_result[0].game_status = '½-½'} 


{:else }

Something completely different.

{/if}

```sql white_vs_black_format
select
     'White' as name,
     num_wins as value,
from lichess_data.white_vs_black
where is_white
union all
select
     'Draw' as name,
     num_draws as value,
from lichess_data.white_vs_black
where is_white
union all
select
     'Black' as name,
     num_wins as value,
from lichess_data.white_vs_black
where not is_white
```

<ECharts config={
    {
        tooltip: {
            trigger: 'item',
            formatter: '{b}: {c} ({d}%)',
            position: 'right'
        },
        title: {
            text: 'Victory Breakdown by Color',
            left: 'center',
            textStyle: {
                fontSize: 24
            }
        },
        legend: {
            top: '5%',
            left: 'right'
        },
        series: [
            {
                type: 'pie',
                radius: ['40%', '70%'],
                data: white_vs_black_format,
                color: ['#f4ebe0', '#121212', '#837F79'],
                emphasis: {
                    label: {
                        show: true,
                        fontSize: 40,
                        fontWeight: 'bold',
                        formatter: function(params){
                            return params.percent.toFixed(1) + '%';
                        }
                    }
                },      
                labelLine: {
                    show: false
                },
                label: {
                    show: false,
                    position: 'center',
                    fontSize: 40,
                    fontWeight: 'bold',
                }
            }, 
        ]
    }
}/>

Over half the games ended in a draw, and of the games which were decisive, 60% were won by white.

```sql opening_breakdown
select *
from lichess_data.detailed_openings
```

## Game Openings

<BarChart
    data={opening_breakdown}
    x=opening_general
    y=total_games
    swapXY=true
    colorPalette='brown'
/>

```sql first_move_breakdown
    select 
        first_move as name,
        count(*) as value,
        count(*) / (select count(*) from game_info) as pct
    from game_info
    group by 1
```

<BarChart
    data={first_move_breakdown}
    x=name
    y=pct
    colorPalette={['#08C2AC']}
    title="First Move"
    yFmt=#,##0.0%
    labels=true
/>

Game openings were as expected, with **e4** at move 1 occurring in almost **70%** of games. The Ruy Lopez and Sicilian are seen as the two sharpest openings in modern classical chess. It makes sense that at the Candidates Tournament, GMs generally stick to safer openings.

