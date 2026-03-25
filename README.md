# 2048

A terminal implementation of the [2048](https://en.wikipedia.org/wiki/2048_(video_game)) sliding tile puzzle, written in Ruby.

## How to play

```
ruby main.rb
```

You will be prompted for a grid size (the standard game uses 4). On each turn, slide all tiles in one direction using the WASD keys:

| Key | Direction |
|-----|-----------|
| `W` | Up        |
| `A` | Left      |
| `S` | Down      |
| `D` | Right     |

When two tiles with the same number collide, they merge into one tile with their sum. A new tile (2 or 4) is placed on the board after every valid move. The game ends when the board is full and no merges are possible.

## Requirements

- Ruby 3.3.6 (see `.ruby-version`)

No gems required.

## Running the tests

```
ruby test_game.rb
```

The test suite uses Ruby's built-in Minitest library — no installation needed.

```
45 runs, 162 assertions, 0 failures, 0 errors, 0 skips
```

## Project structure

```
main.rb        # Game logic (Game2048 class)
test_game.rb   # Minitest test suite
.ruby-version  # Pins Ruby version to 3.3.6
```
