require 'json'

SAVE_FILE = "2048_save.json"

class Game2048
  attr_reader :size, :score
  attr_accessor :grid, :valid_move

  def initialize(size: nil)
    return unless size

    @size       = size
    @grid       = Array.new(@size) { Array.new(@size) }
    @valid_move = false
    @score      = 0
  end

  def full?
    @grid.all? { |row| row.none?(&:nil?) }
  end

  def won?
    @grid.any? { |row| row.any? { |v| v && v >= 2048 } }
  end

  def game_over?
    @grid.each_with_index do |row, r|
      row.each_with_index do |v, c|
        return false if v.nil?
        return false if r > 0              && v == @grid[r - 1][c]
        return false if r < @size - 1     && v == @grid[r + 1][c]
        return false if c > 0              && v == @grid[r][c - 1]
        return false if c < @size - 1     && v == @grid[r][c + 1]
      end
    end
    true
  end

  def up
    @size.times do |c|
      line = Array.new(@size) { |r| @grid[r][c] }
      new_line, moved, delta = slide_line(line)
      @size.times { |r| @grid[r][c] = new_line[r] }
      @valid_move = true if moved
      @score += delta
    end
  end

  def down
    @size.times do |c|
      line = Array.new(@size) { |r| @grid[@size - 1 - r][c] }
      new_line, moved, delta = slide_line(line)
      @size.times { |r| @grid[@size - 1 - r][c] = new_line[r] }
      @valid_move = true if moved
      @score += delta
    end
  end

  def left
    @size.times do |r|
      new_line, moved, delta = slide_line(@grid[r].dup)
      @grid[r] = new_line
      @valid_move = true if moved
      @score += delta
    end
  end

  def right
    @size.times do |r|
      new_line, moved, delta = slide_line(@grid[r].reverse)
      @grid[r] = new_line.reverse
      @valid_move = true if moved
      @score += delta
    end
  end

  def place_tile
    empty = []
    @grid.each_with_index { |row, r| row.each_with_index { |v, c| empty << [r, c] if v.nil? } }
    return if empty.empty?

    r, c = empty.sample
    @grid[r][c] = rand < 0.1 ? 4 : 2
  end

  # Plain-text render kept for non-TUI use and debugging.
  def display
    width = column_width
    separator = (" " + "-" * width) * @size
    @grid.each do |row|
      puts separator
      puts "|" + row.map { |v| v.to_s.rjust(width) }.join("|") + "|"
    end
    puts separator
  end

  def column_width
    @grid.flatten.compact.map { |v| v.to_s.length }.max || 1
  end

  def save_game(path = SAVE_FILE)
    File.write(path, JSON.generate({ "size" => @size, "grid" => @grid, "score" => @score }))
  end

  def load_game(path = SAVE_FILE)
    data    = JSON.parse(File.read(path))
    @size   = data["size"]
    @grid   = data["grid"]
    @score  = data["score"] || 0
    @valid_move = false
  end

  private

  # Slides all non-nil values in +line+ toward index 0, merging equal
  # adjacent tiles once each. Returns [new_line, moved, score_delta].
  def slide_line(line)
    tiles       = line.compact
    merged      = []
    score_delta = 0
    i = 0
    while i < tiles.size
      if i + 1 < tiles.size && tiles[i] == tiles[i + 1]
        val = tiles[i] * 2
        merged << val
        score_delta += val
        i += 2
      else
        merged << tiles[i]
        i += 1
      end
    end
    new_line = merged + Array.new(line.size - merged.size)
    # moved: a merge happened (tile count dropped), or nils weren't already
    # packed at the end (i.e. a nil appears in the first tiles.size slots)
    moved = merged.size < tiles.size || (0...tiles.size).any? { |j| line[j].nil? }
    [new_line, moved, score_delta]
  end
end
