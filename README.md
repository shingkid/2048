# 2048

A terminal implementation of the [2048](https://en.wikipedia.org/wiki/2048_(video_game)) sliding tile puzzle, written in Ruby with a full-colour TUI powered by [bubbletea-ruby](https://github.com/marcoroth/bubbletea-ruby) and [lipgloss-ruby](https://github.com/marcoroth/lipgloss-ruby).

## Requirements

- Ruby 3.3.6 (see `.ruby-version`)
- [Bundler](https://bundler.io/)

## Setup

```
bundle install
```

## How to play

```
ruby main.rb
```

The game is played on the standard 4×4 board. If a saved game exists you will be offered the option to resume it instead.

The board renders in the alternate screen buffer with the classic 2048 colour palette. Slide all tiles in one direction using WASD or the arrow keys:

| Key | Direction |
|-----|-----------|
| `W` / `↑` | Up    |
| `A` / `←` | Left  |
| `S` / `↓` | Down  |
| `D` / `→` | Right |

When two tiles with the same number collide they merge into one tile with their combined value and your score increases accordingly. A new tile (2 or 4) is placed on the board after every valid move.

When you first create a **2048** tile a banner appears — you can keep playing to chase higher tiles. The board supports values well beyond 2048 with a distinct colour for each power of two up to 131,072.

The game ends when the board is full and no merges are possible.

Press **Q** at any time to save and quit. Your board and score are written to `2048_save.json` and restored the next time you run the game. Your all-time best score is saved separately in `2048_best.json` and shown in the header throughout play.

## Running the tests

The test suite exercises only the pure game logic and has no dependency on the TUI gems.

```
ruby test_game.rb
```

```
61 runs, 189 assertions, 0 failures, 0 errors, 0 skips
```

## License

[CC BY-NC 4.0](LICENSE) — free to play, share, and modify; commercial use is not permitted. Inspired by the [original 2048](https://github.com/gabrielecirulli/2048) by Gabriele Cirulli.

## Project structure

```
game.rb        # Pure Game2048 logic (grid, moves, score, save/load)
main.rb        # TUI entry point — GameTUI (Bubbletea::Model) + lipgloss rendering
test_game.rb   # Minitest test suite (no TUI dependencies)
Gemfile        # bubbletea, lipgloss, tty-prompt
.ruby-version  # Pins Ruby version to 3.3.6
```
