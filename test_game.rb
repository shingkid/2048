require 'minitest/autorun'
require_relative 'game'

class Test2048 < Minitest::Test
  def setup
    @game = Game2048.new(size: 4)
  end

  # Sets the grid (and size if different) from a 2-D array literal.
  def set_grid(rows)
    @game.instance_variable_set(:@size, rows.size)
    @game.grid = rows.map(&:dup)
  end

  # Returns all values in column c from top to bottom.
  def col(c)
    (0...@game.size).map { |r| @game.grid[r][c] }
  end

  # ── full? ──────────────────────────────────────────────────────────────────

  def test_full_empty_grid
    refute @game.full?
  end

  def test_full_one_tile
    @game.grid[0][0] = 2
    refute @game.full?
  end

  def test_full_one_nil_remaining
    @game.grid = Array.new(@game.size) { Array.new(@game.size, 2) }
    @game.grid[@game.size - 1][@game.size - 1] = nil
    refute @game.full?
  end

  def test_full_completely_filled
    @game.grid = Array.new(@game.size) { Array.new(@game.size, 2) }
    assert @game.full?
  end

  # ── game_over? ─────────────────────────────────────────────────────────────

  def test_game_over_empty_grid
    refute @game.game_over?
  end

  def test_game_over_single_tile
    @game.grid[0][0] = 2
    refute @game.game_over?
  end

  def test_game_over_full_with_horizontal_merge_available
    val = 2
    @game.grid.each_with_index { |row, r| row.each_with_index { |_, c| @game.grid[r][c] = val; val += 2 } }
    @game.grid[0][0] = @game.grid[0][1]
    refute @game.game_over?
  end

  def test_game_over_full_with_vertical_merge_available
    val = 2
    @game.grid.each_with_index { |row, r| row.each_with_index { |_, c| @game.grid[r][c] = val; val += 2 } }
    @game.grid[0][0] = @game.grid[1][0]
    refute @game.game_over?
  end

  def test_game_over_true_when_full_and_no_merges
    val = 2
    @game.grid.each_with_index { |row, r| row.each_with_index { |_, c| @game.grid[r][c] = val; val += 2 } }
    assert @game.game_over?
  end

  # ── up ─────────────────────────────────────────────────────────────────────

  def test_up_shifts_lone_tile_to_top
    set_grid([[nil, nil, nil, nil],
              [2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.up
    assert_equal 2, @game.grid[0][0]
    assert_nil @game.grid[1][0]
  end

  def test_up_sets_valid_move_on_shift
    set_grid([[nil, nil, nil, nil],
              [2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.up
    assert @game.valid_move
  end

  def test_up_no_valid_move_when_already_packed
    set_grid([[2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.up
    refute @game.valid_move
  end

  def test_up_merges_adjacent_equal_tiles
    set_grid([[2,   nil, nil, nil],
              [2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.up
    assert_equal 4, @game.grid[0][0]
    assert_nil @game.grid[1][0]
  end

  def test_up_merges_equal_tiles_across_gap
    set_grid([[2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [2,   nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.up
    assert_equal 4, @game.grid[0][0]
    assert_nil @game.grid[1][0]
    assert_nil @game.grid[2][0]
  end

  def test_up_no_double_merge
    set_grid([[2, nil, nil, nil],
              [2, nil, nil, nil],
              [2, nil, nil, nil],
              [2, nil, nil, nil]])
    @game.up
    assert_equal [4, 4, nil, nil], col(0)
  end

  def test_up_does_not_merge_different_values
    set_grid([[2,   nil, nil, nil],
              [4,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.up
    assert_equal 2, @game.grid[0][0]
    assert_equal 4, @game.grid[1][0]
  end

  def test_up_handles_multiple_columns_independently
    set_grid([[nil, nil, nil, nil],
              [2,   4,   nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.up
    assert_equal 2, @game.grid[0][0]
    assert_equal 4, @game.grid[0][1]
  end

  # ── down ───────────────────────────────────────────────────────────────────

  def test_down_shifts_lone_tile_to_bottom
    set_grid([[2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.down
    assert_equal 2, @game.grid[3][0]
    assert_nil @game.grid[0][0]
  end

  def test_down_sets_valid_move
    set_grid([[2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.down
    assert @game.valid_move
  end

  def test_down_merges_adjacent_equal_tiles
    set_grid([[nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [2,   nil, nil, nil],
              [2,   nil, nil, nil]])
    @game.down
    assert_equal 4, @game.grid[3][0]
    assert_nil @game.grid[2][0]
  end

  def test_down_no_double_merge
    set_grid([[2, nil, nil, nil],
              [2, nil, nil, nil],
              [2, nil, nil, nil],
              [2, nil, nil, nil]])
    @game.down
    assert_equal [nil, nil, 4, 4], col(0)
  end

  def test_down_merges_equal_tiles_across_gap
    set_grid([[nil, nil, nil, nil],
              [2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [2,   nil, nil, nil]])
    @game.down
    assert_equal 4, @game.grid[3][0]
    assert_nil @game.grid[2][0]
    assert_nil @game.grid[1][0]
  end

  # ── left ───────────────────────────────────────────────────────────────────

  def test_left_shifts_lone_tile_to_leftmost
    set_grid([[nil, nil, 2,   nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left
    assert_equal 2, @game.grid[0][0]
    assert_nil @game.grid[0][2]
  end

  def test_left_sets_valid_move
    set_grid([[nil, 2,   nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left
    assert @game.valid_move
  end

  def test_left_no_valid_move_when_already_packed
    set_grid([[2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left
    refute @game.valid_move
  end

  def test_left_merges_adjacent_equal_tiles
    set_grid([[2,   2,   nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left
    assert_equal 4, @game.grid[0][0]
    assert_nil @game.grid[0][1]
  end

  def test_left_merges_equal_tiles_across_gap
    set_grid([[2,   nil, 2,   nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left
    assert_equal 4, @game.grid[0][0]
    assert_nil @game.grid[0][1]
    assert_nil @game.grid[0][2]
  end

  def test_left_no_double_merge
    set_grid([[2, 2, 2, 2],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left
    assert_equal [4, 4, nil, nil], @game.grid[0]
  end

  def test_left_does_not_merge_different_values
    set_grid([[2,   4,   nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left
    assert_equal 2, @game.grid[0][0]
    assert_equal 4, @game.grid[0][1]
  end

  # ── right ──────────────────────────────────────────────────────────────────

  def test_right_shifts_lone_tile_to_rightmost
    set_grid([[2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.right
    assert_equal 2, @game.grid[0][3]
    assert_nil @game.grid[0][0]
  end

  def test_right_sets_valid_move
    set_grid([[2,   nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.right
    assert @game.valid_move
  end

  def test_right_merges_adjacent_equal_tiles
    set_grid([[nil, nil, 2, 2],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.right
    assert_equal 4, @game.grid[0][3]
    assert_nil @game.grid[0][2]
  end

  def test_right_merges_equal_tiles_across_gap
    set_grid([[nil, 2,   nil, 2],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.right
    assert_equal 4, @game.grid[0][3]
    assert_nil @game.grid[0][2]
    assert_nil @game.grid[0][1]
  end

  def test_right_no_double_merge
    set_grid([[2, 2, 2, 2],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.right
    assert_equal [nil, nil, 4, 4], @game.grid[0]
  end

  # ── place_tile ─────────────────────────────────────────────────────────────

  def test_place_tile_adds_one_tile_to_empty_grid
    @game.place_tile
    assert_equal 1, @game.grid.flatten.compact.size
  end

  def test_place_tile_value_is_2_or_4
    100.times do
      @game.grid = Array.new(@game.size) { Array.new(@game.size) }
      @game.place_tile
      val = @game.grid.flatten.compact.first
      assert [2, 4].include?(val), "Expected 2 or 4, got #{val}"
    end
  end

  def test_place_tile_targets_an_empty_cell
    @game.grid = Array.new(@game.size) { Array.new(@game.size, 2) }
    @game.grid[1][2] = nil
    @game.place_tile
    refute_nil @game.grid[1][2]
  end

  def test_place_tile_does_nothing_when_full
    @game.grid = Array.new(@game.size) { Array.new(@game.size, 2) }
    snapshot = @game.grid.map(&:dup)
    @game.place_tile
    assert_equal snapshot, @game.grid
  end

  # ── column_width ───────────────────────────────────────────────────────────

  def test_column_width_empty_grid_returns_one
    assert_equal 1, @game.column_width
  end

  def test_column_width_single_digit_value
    @game.grid[0][0] = 2
    assert_equal 1, @game.column_width
  end

  def test_column_width_four_digit_value
    @game.grid[0][0] = 2048
    assert_equal 4, @game.column_width
  end

  def test_column_width_uses_largest_value
    @game.grid[0][0] = 8
    @game.grid[1][1] = 1024
    assert_equal 4, @game.column_width
  end

  # ── score ──────────────────────────────────────────────────────────────────

  def test_score_starts_at_zero
    assert_equal 0, @game.score
  end

  def test_score_increases_on_merge
    set_grid([[2, 2, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left
    assert_equal 4, @game.score
  end

  def test_score_accumulates_across_merges
    set_grid([[2, 2, 4, 4],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left
    assert_equal 12, @game.score  # 4 + 8
  end

  def test_score_unaffected_by_non_merging_move
    @game.grid[0][0] = 2
    @game.left
    assert_equal 0, @game.score
  end

  # ── save_game / load_game ──────────────────────────────────────────────────

  def test_save_game_creates_file
    path = "/tmp/test_2048_save_#{$$}.json"
    @game.grid[0][0] = 2
    @game.save_game(path)
    assert File.exist?(path)
  ensure
    File.delete(path) if File.exist?(path)
  end

  def test_save_and_load_round_trip
    path = "/tmp/test_2048_save_#{$$}.json"
    @game.grid[0][0] = 2
    @game.grid[1][2] = 512
    @game.save_game(path)

    other = Game2048.new(size: 4)
    other.load_game(path)
    assert_equal @game.size,  other.size
    assert_equal @game.grid,  other.grid
    assert_equal @game.score, other.score
  ensure
    File.delete(path) if File.exist?(path)
  end

  def test_save_and_load_preserves_score
    path = "/tmp/test_2048_save_#{$$}.json"
    set_grid([[2, 2, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil],
              [nil, nil, nil, nil]])
    @game.left   # merges → score = 4
    @game.save_game(path)

    other = Game2048.new(size: 4)
    other.load_game(path)
    assert_equal 4, other.score
  ensure
    File.delete(path) if File.exist?(path)
  end

  def test_load_game_restores_size
    path = "/tmp/test_2048_save_#{$$}.json"
    game3 = Game2048.new(size: 3)
    game3.grid[0][0] = 4
    game3.save_game(path)

    other = Game2048.new(size: 4)
    other.load_game(path)
    assert_equal 3, other.size
  ensure
    File.delete(path) if File.exist?(path)
  end

  def test_save_preserves_nil_cells
    path = "/tmp/test_2048_save_#{$$}.json"
    @game.grid[0][0] = 8
    @game.save_game(path)
    other = Game2048.new(size: 4)
    other.load_game(path)
    assert_nil other.grid[0][1]
    assert_equal 8, other.grid[0][0]
  ensure
    File.delete(path) if File.exist?(path)
  end

  # ── display (smoke) ────────────────────────────────────────────────────────

  def test_display_does_not_crash_on_empty_grid
    capture_io { @game.display }
  end

  def test_display_does_not_crash_with_tiles
    @game.grid[0][0] = 2
    @game.grid[1][1] = 1024
    capture_io { @game.display }
  end

  def test_display_contains_tile_values
    @game.grid[0][0] = 512
    out, = capture_io { @game.display }
    assert_includes out, "512"
  end
end
