---
title: "Chessray: A Deeper Dive into the 2024 FIDE Candidates Tournament"
---

[Github Repo](https://github.com/adgramigna/chess-data) containing code which calls the Lichess API, stores raw data in S3, transforms data using dbt, and finally visualizes data in Evidence.

# Data

- Data is pulled from the [Lichess Broadcasts API](https://lichess.org/api#tag/Broadcasts)
- Engine Evaluation is taken from the comments of the game's [PGN](https://en.wikipedia.org/wiki/Portable_Game_Notation) annotated by Lichess
- PGN parsing is done with the [python-chess](https://github.com/niklasf/python-chess) library
- Data is cleaned and transformed using dbt, specifically [dbt-duckdb](https://github.com/duckdb/dbt-duckdb)

# Definitions

## General
  - *Move*: One move in chess is considered a move by both white and black. So when we say the average game lasted 46 moves, white and black each averaged 46 moves.
  - *Endgame*: Major pieces + minor pieces less than or equal to 6
  - *Game Openings*: Parsed directly from PGN annotated by Lichess 

## Time pressure categories:
  - *no time pressure*: >= 5 minutes remaining on the player's clock
  - *time pressure*: Between 1 and 5 minutes remaining on the player's clock
  - *severe time pressure*: less than 60 seconds remaining on the player's clock

## Accuracy:
  - Accuracy is calculated similar to [Lichess' Accuracy Formula](https://lichess.org/page/accuracy). 
    - [This blog post](https://lichess.org/@/JoaoTx/blog/exploring-the-python-chess-module/P0nb4FEs) helped me create my own accuracy calculation.
  - Accuracy varies depending on methodology. There is not a standard agreed upon way to calculate accuracy, which is why my numbers will differ from Lichess which will differ from chess.com

## Poor Moves:
  - *Poor Move*: An innacuracy, mistake, or blunder
  - *Inacurracy/Mistake/Blunder*: Different types of poor moves defined by how much the engine evaluation swings in the opponents favor after the move is made. Blunders are the most severe poor moves, inaccuracies are the least.

## Winning Advantage
  - *Winning Advantage*: I deemed this to be when the engine evaluation of the position tilts >= 1.50 in either direction. Note that this is subjective, and positions of the same engine evaluation can have vastly different complexities. The goal of this is to provide a heuristic useful for assessing performance, it is not perfect.
  - *Converting Winning Advantage*: Having winning advantage at some point in the game, and ultimately winning.
  - *Saving Losing Position*: Opponent has a winning advantage at some point in the game, and ultimately they do not win.