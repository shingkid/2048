require 'bubbletea'
require 'lipgloss'
require 'tty-prompt'
require_relative 'game'

# Colour palette for every tile value the game can produce.
#
# 2–2048:   classic warm progression (beige → orange → gold)
# 4096+:    cool progression (purple → blue) — visually distinct from the
#           warm range so players immediately recognise a rare achievement
#
# Ruby integers are arbitrary precision so there is no numeric overflow.
# CELL_WIDTH = 7 accommodates values up to 9,999,999 (< 2^24).  The highest
# tile ever recorded on a 4×4 board is 131,072 (2^17, 6 digits); anything
# beyond the defined palette falls back to a high-contrast dark style.
TILE_COLORS = {
  nil    => { fg: "#776e65", bg: "#cdc1b4" },
  2      => { fg: "#776e65", bg: "#eee4da" },
  4      => { fg: "#776e65", bg: "#ede0c8" },
  8      => { fg: "#f9f6f2", bg: "#f2b179" },
  16     => { fg: "#f9f6f2", bg: "#f59563" },
  32     => { fg: "#f9f6f2", bg: "#f67c5f" },
  64     => { fg: "#f9f6f2", bg: "#f65e3b" },
  128    => { fg: "#f9f6f2", bg: "#edcf72" },
  256    => { fg: "#f9f6f2", bg: "#edcc61" },
  512    => { fg: "#f9f6f2", bg: "#edc850" },
  1024   => { fg: "#f9f6f2", bg: "#edc53f" },
  2048   => { fg: "#f9f6f2", bg: "#edc22e" },
  4096   => { fg: "#f9f6f2", bg: "#7c5cbf" },
  8192   => { fg: "#f9f6f2", bg: "#6a4aad" },
  16384  => { fg: "#f9f6f2", bg: "#57389b" },
  32768  => { fg: "#f9f6f2", bg: "#2980b9" },
  65536  => { fg: "#f9f6f2", bg: "#1f6fa8" },
  131072 => { fg: "#f9f6f2", bg: "#145e97" },
}.freeze

# Fallback style for tiles beyond the defined palette (large grids / long games).
OVERFLOW_TILE_COLORS = { fg: "#ffffff", bg: "#1a1a1a" }.freeze

class GameTUI
  include Bubbletea::Model

  CELL_WIDTH  = 7   # interior character width — handles up to 7-digit values (< 2^24)
  CELL_HEIGHT = 3   # interior line height of each tile

  def initialize(game)
    @game    = game
    @message = nil
    build_styles
  end

  def init
    [self, Bubbletea.set_window_title("2048")]
  end

  def update(msg)
    case msg
    when Bubbletea::KeyMessage then handle_key(msg.to_s)
    else [self, nil]
    end
  end

  def view
    [header_view, "", grid_view, "", footer_view].join("\n")
  end

  private

  # ── key handling ────────────────────────────────────────────────────────────

  def handle_key(key)
    if @game.game_over?
      return [self, Bubbletea.quit] if key == "q" || key == "ctrl+c"
      return [self, nil]
    end

    case key
    when "w", "up"    then apply_move(:up)
    when "a", "left"  then apply_move(:left)
    when "s", "down"  then apply_move(:down)
    when "d", "right" then apply_move(:right)
    when "q", "ctrl+c"
      @game.save_game
      [self, Bubbletea.quit]
    else
      [self, nil]
    end
  end

  def apply_move(direction)
    @game.valid_move = false
    @game.send(direction)
    if @game.valid_move
      @game.place_tile
      @message = nil
      File.delete(SAVE_FILE) if @game.game_over? && File.exist?(SAVE_FILE)
    else
      @message = "No tiles moved."
    end
    [self, nil]
  end

  # ── view helpers ────────────────────────────────────────────────────────────

  def header_view
    title       = @style_title.render("2048")
    score_label = @style_score_label.render("Score: ")
    score_value = @style_score_value.render(@game.score.to_s)
    Lipgloss.join_horizontal(:center, title, "  ", score_label, score_value)
  end

  def grid_view
    rows = @game.grid.map do |row|
      Lipgloss.join_horizontal(:top, *row.map { |v| render_tile(v) })
    end
    Lipgloss.join_vertical(:left, *rows)
  end

  def render_tile(value)
    style = value ? (@tile_styles[value] || @tile_style_overflow) : @tile_styles[nil]
    style.render(value ? value.to_s : "")
  end

  def footer_view
    if @game.game_over?
      @style_game_over.render("Game over!  Press Q to exit.")
    else
      hint = @style_hint.render("WASD / ↑↓←→: move   Q: save & quit")
      msg  = @message ? @style_message.render("   #{@message}") : ""
      hint + msg
    end
  end

  # ── style cache (built once in initialize) ──────────────────────────────────

  def build_styles
    @style_title       = Lipgloss::Style.new.bold(true).foreground("#f9f6f2").background("#776e65").padding(0, 2)
    @style_score_label = Lipgloss::Style.new.foreground("#776e65")
    @style_score_value = Lipgloss::Style.new.bold(true).foreground("#f65e3b")
    @style_hint        = Lipgloss::Style.new.faint(true)
    @style_game_over   = Lipgloss::Style.new.bold(true).foreground("#f65e3b")
    @style_message     = Lipgloss::Style.new.foreground("#f59563")

    base_tile = Lipgloss::Style.new.width(CELL_WIDTH).height(CELL_HEIGHT).align(:center, :center)

    @tile_styles = TILE_COLORS.each_with_object({}) do |(val, colors), h|
      style = base_tile.foreground(colors[:fg]).background(colors[:bg])
      style = style.bold(true) unless val.nil?
      h[val] = style
    end

    # Used for any tile value not in the palette (very large grids / long games).
    @tile_style_overflow = base_tile
      .bold(true)
      .foreground(OVERFLOW_TILE_COLORS[:fg])
      .background(OVERFLOW_TILE_COLORS[:bg])
  end
end

# ── Entry point ──────────────────────────────────────────────────────────────

if __FILE__ == $0
  unless Bubbletea.tty?
    puts "Error: a TTY is required to run the TUI."
    exit 1
  end

  prompt = TTY::Prompt.new

  game =
    if File.exist?(SAVE_FILE) && prompt.yes?("Saved game found. Load it?")
      g = Game2048.new
      g.load_game
      g
    else
      size = prompt.ask("Grid size:", default: "4", convert: :int)
      g = Game2048.new(size: size)
      g.place_tile
      g.place_tile
      g
    end

  Bubbletea.run(GameTUI.new(game), alt_screen: true)
end
