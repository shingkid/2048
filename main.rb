class Game2048
  attr_reader :size, :valid_move
  attr_accessor :grid

  def initialize(size: nil)
    return unless size

    @size = size
    @grid = Array.new(@size) { Array.new(@size) }
    @valid_move = false
  end

  def play
    puts "---- 2048 ----"
    print "Enter grid length: "
    @size = prompt_size
    @grid = Array.new(@size) { Array.new(@size) }
    @valid_move = false
    place_tile
    display

    until game_over?
      @valid_move = false
      print "W/A/S/D? "
      move(gets.chomp.upcase)
      if @valid_move
        place_tile
      else
        puts "Invalid move."
      end
      display
    end

    puts "Game over!"
  end

  def full?
    @grid.all? { |row| row.none?(&:nil?) }
  end

  def game_over?
    @grid.each_with_index do |row, r|
      row.each_with_index do |v, c|
        return false if v.nil?
        return false if r > 0 && v == @grid[r - 1][c]
        return false if r < @size - 1 && v == @grid[r + 1][c]
        return false if c > 0 && v == @grid[r][c - 1]
        return false if c < @size - 1 && v == @grid[r][c + 1]
      end
    end
    true
  end

  def move(input)
    case input
    when "W" then up
    when "A" then left
    when "S" then down
    when "D" then right
    else
      print "Use W, A, S, or D: "
      move(gets.chomp.upcase)
    end
  end

  def up
    @size.times do |c|
      line = @size.times.map { |r| @grid[r][c] }
      new_line, moved = slide_line(line)
      @size.times { |r| @grid[r][c] = new_line[r] }
      @valid_move = true if moved
    end
  end

  def down
    @size.times do |c|
      line = @size.times.map { |r| @grid[r][c] }.reverse
      new_line, moved = slide_line(line)
      new_line.reverse!
      @size.times { |r| @grid[r][c] = new_line[r] }
      @valid_move = true if moved
    end
  end

  def left
    @size.times do |r|
      new_line, moved = slide_line(@grid[r].dup)
      @grid[r] = new_line
      @valid_move = true if moved
    end
  end

  def right
    @size.times do |r|
      new_line, moved = slide_line(@grid[r].reverse)
      @grid[r] = new_line.reverse
      @valid_move = true if moved
    end
  end

  def place_tile
    return if full?

    loop do
      r, c = rand(@size), rand(@size)
      next unless @grid[r][c].nil?

      @grid[r][c] = rand < 0.3 ? 4 : 2
      break
    end
  end

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

  private

  def prompt_size
    Integer(gets.chomp)
  rescue ArgumentError
    print "Please enter an integer: "
    retry
  end

  # Slides all non-nil values in +line+ toward index 0, merging equal
  # adjacent tiles once each. Returns [new_line, moved].
  def slide_line(line)
    tiles = line.compact
    merged = []
    i = 0
    while i < tiles.size
      if i + 1 < tiles.size && tiles[i] == tiles[i + 1]
        merged << tiles[i] * 2
        i += 2
      else
        merged << tiles[i]
        i += 1
      end
    end
    new_line = merged + Array.new(line.size - merged.size)
    [new_line, new_line != line]
  end
end

Game2048.new.play if __FILE__ == $0
