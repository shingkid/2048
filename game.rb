require 'json'

SAVE_FILE = "2048_save.json"
BEST_FILE = "2048_best.json"

class Game2048
  attr_reader :size, :score
  attr_accessor :grid

  def self.load_best(path = BEST_FILE)
    return 0 unless File.exist?(path)
    JSON.parse(File.read(path))["best"] || 0
  rescue JSON::ParserError
    0
  end

  def self.save_best(score, path = BEST_FILE)
    File.write(path, JSON.generate({ "best" => score }))
  end

  def initialize(size: nil)
    return unless size

    @size  = size
    @grid  = Array.new(@size) { Array.new(@size) }
    @score = 0
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

  def up    = slide_lines { |i| (0...@size).map { |r| [r, i] } }
  def down  = slide_lines { |i| (0...@size).map { |r| [@size - 1 - r, i] } }
  def left  = slide_lines { |i| (0...@size).map { |c| [i, c] } }
  def right = slide_lines { |i| (0...@size).map { |c| [i, @size - 1 - c] } }

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
    data   = JSON.parse(File.read(path))
    @size  = data["size"]
    @grid  = data["grid"]
    @score = data["score"] || 0
  end

  private

  # Applies slide_line across every row/column described by the block.
  # The block receives an index 0..size-1 and returns an ordered array of
  # [row, col] coordinates representing one line to slide toward index 0.
  def slide_lines
    moved = false
    @size.times do |i|
      coords   = yield(i)
      line     = coords.map { |r, c| @grid[r][c] }
      new_line, did_move, delta = slide_line(line)
      coords.each_with_index { |(r, c), j| @grid[r][c] = new_line[j] }
      moved = true if did_move
      @score += delta
    end
    moved
  end

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
