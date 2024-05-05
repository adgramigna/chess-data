---
title: "Chessray: A Deeper Dive into the 2024 FIDE Candidates Tournament"
---

<Details title='How to edit this page'>
  This page can be found in your project at `/pages/index.md`. Make a change to the markdown file and save it to see the change take effect in your browser.
</Details>

```sql leaderboard
select 
    player_name,
    sum(num_points) as points,
    sum(case when num_points = 1 then 1 else 0 end) as wins, 
    sum(case when num_points = 0.5 then 1 else 0 end) as draws, 
    sum(case when num_points = 0 then 1 else 0 end) as losses, 
from lichess_data.player_game_info
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

```sql accuracy
    select 
        colloquial_name, 
        tournament_id, 
        count(distinct game_id) as total_games,
        avg(accuracy) / 100 as accuracy
    from player_game_info
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

Accuracy is calculated similar to [Lichess' Accuracy Formula](https://lichess.org/page/accuracy). Despite having no losses and the highest accuracy, Nepo could not top Gukesh. [This blog post](https://lichess.org/@/JoaoTx/blog/exploring-the-python-chess-module/P0nb4FEs) helped me create my own accuracy calculation.


```sql game_info
select * exclude(white_player, black_player),
    case 
        when left(split_part(white_player, ', ', 1), 4) = 'Nepo' then 'Nepo'
        when left( split_part(white_player, ', ', 2), 5) = 'Pragg' then 'Pragg'
        when len(split_part(white_player, ', ', 1)) = 1 then split_part(white_player, ', ', 2)
        else split_part(white_player, ', ', 1)
    end as white_player,
    case 
        when left(split_part(black_player, ', ', 1), 4) = 'Nepo' then 'Nepo'
        when left( split_part(black_player, ', ', 2), 5) = 'Pragg' then 'Pragg'
        when len(split_part(black_player, ', ', 1)) = 1 then split_part(black_player, ', ', 2)
        else split_part(black_player, ', ', 1)
    end as black_player,
from lichess_data.game_info
```

## Poor Moves by Player

<Heatmap 
    data={game_info} 
    x=white_player 
    y=black_player
    value=total_poor_moves
    subtitle="White Player Horizontal Black Player Vertical"
    xLabelRotation=-45
    xSort=white_player
    ySort=black_player
    colorPalette={['#fde725', '#a0da39', '#4ac16d', '#1fa187', '#277f8e', '#365c8d', '#46327e', '#440154']}
/>

Gukesh vs Abasov was the biggest blunderfest of the tournament, with the infamous Fabi/Nepo round 14 game as a close second. Another key insight from this shows Nepo was unable to capitalize in games with the white pieces. Despite not losing a single game, in games where Nepo needed to push for a win, either his opponents defended incredibly well, or he was unable to bring them into complicated positions. 

```sql categories
  select
      category
  from needful_things.orders
  group by category
```

<Dropdown data={categories} name=category value=category>
    <DropdownOption value="%" valueLabel="All Categories"/>
</Dropdown>

<Dropdown name=year>
    <DropdownOption value=% valueLabel="All Years"/>
    <DropdownOption value=2019/>
    <DropdownOption value=2020/>
    <DropdownOption value=2021/>
</Dropdown>

```sql orders_by_category
  select 
      date_trunc('month', order_datetime) as month,
      sum(sales) as sales_usd,
      category
  from needful_things.orders
  where category like '${inputs.category.value}'
  and date_part('year', order_datetime) like '${inputs.year.value}'
  group by all
  order by sales_usd desc
```

<BarChart
    data={orders_by_category}
    title="Sales by Month, {inputs.category.label}"
    x=month
    y=sales_usd
    series=category
/>

## What's Next?
- [Connect your data sources](settings)
- Edit/add markdown files in the `pages` folder
- Deploy your project with [Evidence Cloud](https://evidence.dev/cloud)

## Get Support
- Message us on [Slack](https://slack.evidence.dev/)
- Read the [Docs](https://docs.evidence.dev/)
- Open an issue on [Github](https://github.com/evidence-dev/evidence)
