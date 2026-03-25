require 'minitest/autorun'

# Load game functions without triggering play()
eval(File.read(File.join(__dir__, 'main.rb')).sub(/\nplay\(\)\n?$/, ''))

class Test2048 < Minitest::Test
  def setup
    $l = 4
    $grid = Array.new($l) { Array.new($l) }
    $valid_move = false
  end

  # Sets $grid and $l from a 2-D array literal, e.g. [[2,nil],[nil,4]]
  def set_grid(rows)
    $l = rows.size
    $grid = rows.map(&:dup)
  end

  # Returns the values in column c from top to bottom
  def col(c)
    (0...$l).map { |r| $grid[r][c] }
  end

  # ── full? ──────────────────────────────────────────────────────────────────

  def test_full_empty_grid
    refute full?
  end

  def test_full_one_tile
    $grid[0][0] = 2
    refute full?
  end

  def test_full_one_nil_remaining
    $grid = Array.new($l) { Array.new($l, 2) }
    $grid[$l-1][$l-1] = nil
    refute full?
  end

  def test_full_completely_filled
    $grid = Array.new($l) { Array.new($l, 2) }
    assert full?
  end

  # ── game_over? ─────────────────────────────────────────────────────────────

  def test_game_over_empty_grid
    refute game_over?
  end

  def test_game_over_single_tile
    $grid[0][0] = 2
    refute game_over?
  end

  def test_game_over_full_with_horizontal_merge_available
    val = 2
    $grid.each_with_index { |row, r| row.each_with_index { |_, c| $grid[r][c] = val; val += 2 } }
    $grid[0][0] = $grid[0][1]   # two equal neighbours in a row
    refute game_over?
  end

  def test_game_over_full_with_vertical_merge_available
    val = 2
    $grid.each_with_index { |row, r| row.each_with_index { |_, c| $grid[r][c] = val; val += 2 } }
    $grid[0][0] = $grid[1][0]   # two equal neighbours in a column
    refute game_over?
  end

  def test_game_over_true_when_full_and_no_merges
    # Fill with all distinct values so no two adjacent cells are equal
    val = 2
    $grid.each_with_index { |row, r| row.each_with_index { |_, c| $grid[r][c] = val; val += 2 } }
    assert game_over?
  end

  # ── up ─────────────────────────────────────────────────────────────────────

  def test_up_shifts_lone_tile_to_top
    set_grid([[nil,nil,nil,nil],
              [2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    up
    assert_equal 2, $grid[0][0]
    assert_nil $grid[1][0]
  end

  def test_up_sets_valid_move_on_shift
    set_grid([[nil,nil,nil,nil],
              [2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    up
    assert $valid_move
  end

  def test_up_no_valid_move_when_already_packed
    set_grid([[2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    up
    refute $valid_move
  end

  def test_up_merges_adjacent_equal_tiles
    set_grid([[2,  nil,nil,nil],
              [2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    up
    assert_equal 4, $grid[0][0]
    assert_nil $grid[1][0]
  end

  def test_up_merges_equal_tiles_across_gap
    set_grid([[2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [2,  nil,nil,nil],
              [nil,nil,nil,nil]])
    up
    assert_equal 4, $grid[0][0]
    assert_nil $grid[1][0]
    assert_nil $grid[2][0]
  end

  def test_up_no_double_merge
    set_grid([[2,nil,nil,nil],
              [2,nil,nil,nil],
              [2,nil,nil,nil],
              [2,nil,nil,nil]])
    up
    assert_equal [4, 4, nil, nil], col(0)
  end

  def test_up_does_not_merge_different_values
    set_grid([[2,  nil,nil,nil],
              [4,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    up
    assert_equal 2, $grid[0][0]
    assert_equal 4, $grid[1][0]
  end

  def test_up_handles_multiple_columns_independently
    set_grid([[nil,nil,nil,nil],
              [2,  4,  nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    up
    assert_equal 2, $grid[0][0]
    assert_equal 4, $grid[0][1]
  end

  # ── down ───────────────────────────────────────────────────────────────────

  def test_down_shifts_lone_tile_to_bottom
    set_grid([[2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    down
    assert_equal 2, $grid[3][0]
    assert_nil $grid[0][0]
  end

  def test_down_sets_valid_move
    set_grid([[2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    down
    assert $valid_move
  end

  def test_down_merges_adjacent_equal_tiles
    set_grid([[nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [2,  nil,nil,nil],
              [2,  nil,nil,nil]])
    down
    assert_equal 4, $grid[3][0]
    assert_nil $grid[2][0]
  end

  def test_down_no_double_merge
    set_grid([[2,nil,nil,nil],
              [2,nil,nil,nil],
              [2,nil,nil,nil],
              [2,nil,nil,nil]])
    down
    assert_equal [nil, nil, 4, 4], col(0)
  end

  def test_down_merges_equal_tiles_across_gap
    set_grid([[nil,nil,nil,nil],
              [2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [2,  nil,nil,nil]])
    down
    assert_equal 4, $grid[3][0]
    assert_nil $grid[2][0]
    assert_nil $grid[1][0]
  end

  # ── left ───────────────────────────────────────────────────────────────────

  def test_left_shifts_lone_tile_to_leftmost
    set_grid([[nil,nil,2,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    left
    assert_equal 2, $grid[0][0]
    assert_nil $grid[0][2]
  end

  def test_left_sets_valid_move
    set_grid([[nil,2,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    left
    assert $valid_move
  end

  def test_left_no_valid_move_when_already_packed
    set_grid([[2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    left
    refute $valid_move
  end

  def test_left_merges_adjacent_equal_tiles
    set_grid([[2,2,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    left
    assert_equal 4, $grid[0][0]
    assert_nil $grid[0][1]
  end

  def test_left_merges_equal_tiles_across_gap
    set_grid([[2,nil,2,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    left
    assert_equal 4, $grid[0][0]
    assert_nil $grid[0][1]
    assert_nil $grid[0][2]
  end

  def test_left_no_double_merge
    set_grid([[2,2,2,2],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    left
    assert_equal [4, 4, nil, nil], $grid[0]
  end

  def test_left_does_not_merge_different_values
    set_grid([[2,4,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    left
    assert_equal 2, $grid[0][0]
    assert_equal 4, $grid[0][1]
  end

  # ── right ──────────────────────────────────────────────────────────────────

  def test_right_shifts_lone_tile_to_rightmost
    set_grid([[2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    right
    assert_equal 2, $grid[0][3]
    assert_nil $grid[0][0]
  end

  def test_right_sets_valid_move
    set_grid([[2,  nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    right
    assert $valid_move
  end

  def test_right_merges_adjacent_equal_tiles
    set_grid([[nil,nil,2,2],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    right
    assert_equal 4, $grid[0][3]
    assert_nil $grid[0][2]
  end

  def test_right_merges_equal_tiles_across_gap
    set_grid([[nil,2,nil,2],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    right
    assert_equal 4, $grid[0][3]
    assert_nil $grid[0][2]
    assert_nil $grid[0][1]
  end

  def test_right_no_double_merge
    set_grid([[2,2,2,2],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil],
              [nil,nil,nil,nil]])
    right
    assert_equal [nil, nil, 4, 4], $grid[0]
  end

  # ── new_block ──────────────────────────────────────────────────────────────

  def test_new_block_places_one_tile_on_empty_grid
    new_block
    assert_equal 1, $grid.flatten.compact.size
  end

  def test_new_block_places_2_or_4
    100.times do
      $grid = Array.new($l) { Array.new($l) }
      new_block
      val = $grid.flatten.compact.first
      assert [2, 4].include?(val), "Expected 2 or 4, got #{val}"
    end
  end

  def test_new_block_places_tile_in_empty_cell
    $grid = Array.new($l) { Array.new($l, 2) }
    $grid[1][2] = nil
    new_block
    refute_nil $grid[1][2]
  end

  def test_new_block_does_nothing_when_full
    $grid = Array.new($l) { Array.new($l, 2) }
    snapshot = $grid.map(&:dup)
    new_block
    assert_equal snapshot, $grid
  end

  # ── calculate_spaces ───────────────────────────────────────────────────────

  def test_calculate_spaces_empty_grid_returns_one
    assert_equal 1, calculate_spaces
  end

  def test_calculate_spaces_single_digit_value
    $grid[0][0] = 2
    assert_equal 1, calculate_spaces
  end

  def test_calculate_spaces_four_digit_value
    $grid[0][0] = 2048
    assert_equal 4, calculate_spaces
  end

  def test_calculate_spaces_uses_largest_value
    $grid[0][0] = 8
    $grid[1][1] = 1024
    assert_equal 4, calculate_spaces
  end

  # ── display (smoke) ────────────────────────────────────────────────────────

  def test_display_does_not_crash_on_empty_grid
    capture_io { display }
  end

  def test_display_does_not_crash_with_tiles
    $grid[0][0] = 2
    $grid[1][1] = 1024
    capture_io { display }
  end

  def test_display_contains_tile_values
    $grid[0][0] = 512
    out, = capture_io { display }
    assert_includes out, '512'
  end
end
