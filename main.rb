def play
    puts "---- 2048 ----"
    print "Enter grid length: "
    begin
        $l = Integer(gets.chomp)
    rescue
        print "Please enter an integer number: "
        retry
    end

    $grid = Array.new($l) { Array.new($l) }
    new_block()
    display()

    while !game_over?()
        $valid_move = false
        print "Up, Down, Right or Left? "
        input = gets.chomp
        move(input.upcase)
        if $valid_move
            new_block()
        else
            puts "Invalid move."
        end
        display()
    end

    puts "Game over!"
end

def full?
    $grid.each {|x| x.each {|y| return false if y == nil}}
    return true
end

def move(input)
    case input
    when "W"
        up()
    when "A"
        left()
    when "S"
        down()
    when "D"
        right()
    when Integer
        print "You entered a number. Choose a direction (W,A,S,D): "
        input = gets.chomp
        move(input.upcase)
    when String
        print "Use W, A, S, or D: "
        input = gets.chomp
        move(input.upcase)
    end
end

def up
    merged = Array.new($l) { Array.new($l, false) }
    for r in 1...$l
        for c in 0...$l
            if $grid[r][c] != nil
                new_r = -1
                for i in 1..r
                    if $grid[r-i][c] == nil
                        new_r = r - i
                    else
                        break
                    end
                end
                if new_r != -1
                    $grid[new_r][c] = $grid[r][c]
                    $grid[r][c] = nil
                    $valid_move = true
                    if new_r > 0 && !merged[new_r-1][c] && $grid[new_r-1][c] == $grid[new_r][c]
                        $grid[new_r-1][c] *= 2
                        $grid[new_r][c] = nil
                        merged[new_r-1][c] = true
                    end
                elsif r > 0 && !merged[r-1][c] && $grid[r-1][c] == $grid[r][c]
                    $grid[r-1][c] *= 2
                    $grid[r][c] = nil
                    $valid_move = true
                    merged[r-1][c] = true
                end
            end
        end
    end
end

def down
    merged = Array.new($l) { Array.new($l, false) }
    for r in ($l-2).downto(0)
        for c in 0...$l
            if $grid[r][c] != nil
                new_r = -1
                for i in 1...($l-r)
                    if $grid[r+i][c] == nil
                        new_r = r + i
                    else
                        break
                    end
                end
                if new_r != -1
                    $grid[new_r][c] = $grid[r][c]
                    $grid[r][c] = nil
                    $valid_move = true
                    if new_r < $l - 1 && !merged[new_r+1][c] && $grid[new_r+1][c] == $grid[new_r][c]
                        $grid[new_r+1][c] *= 2
                        $grid[new_r][c] = nil
                        merged[new_r+1][c] = true
                    end
                elsif r < $l - 1 && !merged[r+1][c] && $grid[r+1][c] == $grid[r][c]
                    $grid[r+1][c] *= 2
                    $grid[r][c] = nil
                    $valid_move = true
                    merged[r+1][c] = true
                end
            end
        end
    end
end

def right
    merged = Array.new($l) { Array.new($l, false) }
    for r in 0...$l
        for c in ($l-2).downto(0)
            if $grid[r][c] != nil
                new_c = -1
                for i in 1...($l-c)
                    if $grid[r][c+i] == nil
                        new_c = c + i
                    else
                        break
                    end
                end
                if new_c != -1
                    $grid[r][new_c] = $grid[r][c]
                    $grid[r][c] = nil
                    $valid_move = true
                    if new_c < $l - 1 && !merged[r][new_c+1] && $grid[r][new_c+1] == $grid[r][new_c]
                        $grid[r][new_c+1] *= 2
                        $grid[r][new_c] = nil
                        merged[r][new_c+1] = true
                    end
                elsif c < $l - 1 && !merged[r][c+1] && $grid[r][c+1] == $grid[r][c]
                    $grid[r][c+1] *= 2
                    $grid[r][c] = nil
                    $valid_move = true
                    merged[r][c+1] = true
                end
            end
        end
    end
end

def left
    merged = Array.new($l) { Array.new($l, false) }
    for r in 0...$l
        for c in 1...$l
            if $grid[r][c] != nil
                new_c = -1
                for i in 1..c
                    if $grid[r][c-i] == nil
                        new_c = c - i
                    else
                        break
                    end
                end
                if new_c != -1
                    $grid[r][new_c] = $grid[r][c]
                    $grid[r][c] = nil
                    $valid_move = true
                    if new_c > 0 && !merged[r][new_c-1] && $grid[r][new_c-1] == $grid[r][new_c]
                        $grid[r][new_c-1] *= 2
                        $grid[r][new_c] = nil
                        merged[r][new_c-1] = true
                    end
                elsif c > 0 && !merged[r][c-1] && $grid[r][c-1] == $grid[r][c]
                    $grid[r][c-1] *= 2
                    $grid[r][c] = nil
                    $valid_move = true
                    merged[r][c-1] = true
                end
            end
        end
    end
end

def display
    req_space = calculate_spaces()
    for i in 0...$l
        for j in 0...$l
            print " "
            for _ in 0...req_space
                print "-"
            end
        end
        puts
        print "|"
        for j in 0...$l
            v = $grid[i][j]
            if v == nil
                v = ""
                for _ in 0...req_space
                    v += " "
                end
            end
            v = v.to_s
            for _ in 0...(req_space-v.length)
                print " "
            end
            print v.to_s + "|"
        end
        puts
    end
    for j in 0...$l
        print " "
        for _ in 0...req_space
            print "-"
        end
    end
    puts
end

def calculate_spaces
    max = 1
    for r in 0...$l
        for c in 0...$l
            len = $grid[r][c].to_s.length
            if len > max
                max = len
            end
        end
    end
    return max
end

def new_block
    return if full?()
    rand_r = nil
    rand_c = nil
    loop do
        rand_r = rand($l)
        rand_c = rand($l)
        break if $grid[rand_r][rand_c] == nil
    end
    if rand() > 0.7
        $grid[rand_r][rand_c] = 4
    else
        $grid[rand_r][rand_c] = 2
    end
end

def game_over?
    for r in 0...$l
        for c in 0...$l
            v = $grid[r][c]
            if v == nil
                return false
            end
            if r > 0 && v == $grid[r-1][c] \
                || r < $l - 1 && v == $grid[r+1][c] \
                || c > 0 && v == $grid[r][c-1] \
                || c < $l - 1 && v == $grid[r][c+1]
                return false
            end
        end
    end
    return true
end

play()
