=begin
    Bugs:
    1. Game ends once grid is full even if more moves can be made
    2. Combines successively when it shouldn't
=end
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
        
    while !full?() & !game_over?()
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

    print "Up, Down, Right or Left? "
    input = gets.chomp
    move(input.upcase)
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
    when Fixnum
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
    for r in 1...$l
        for c in 0...$l
            if $grid[r][c] != nil
                # puts "Cell: " + r.to_s + ", " + c.to_s
                # if cell above is empty, shift up
                new_r = -1
                for i in 1..r
                    # print "Cell above: " + (r-i).to_s + ", " + c.to_s
                    if $grid[r-i][c] == nil
                        # puts " is empty"
                        # if block directly above is empty, update new row to move to
                        new_r = r - i
                    else
                        # puts " is not empty"
                        break
                    end
                end
                if new_r != -1
                    # puts "new_r was updated"
                    $grid[new_r][c] = $grid[r][c]
                    $grid[r][c] = nil
                    $valid_move = true
                    # if $grid[r][c] == nil
                    #     display()
                    # end
                    if new_r > 0 && $grid[new_r-1][c] == $grid[new_r][c]
                        # puts "Can combine"
                        $grid[new_r-1][c] *= 2
                        $grid[new_r][c] = nil
                        display()
                    end
                elsif r > 0 && $grid[r-1][c] == $grid[r][c]
                    # puts "Can combine"
                    $grid[r-1][c] *= 2
                    $grid[r][c] = nil
                    $valid_move = true
                    # display()
                end
            end
        end
    end
end

def down
    for r in ($l-2).downto(0)
        for c in 0...$l
            if $grid[r][c] != nil
                # puts "Cell: " + r.to_s + ", " + c.to_s
                # if cell below is empty, shift down
                new_r = -1
                for i in 1...($l-r)
                    # print "Cell below: " + (r+i).to_s + ", " + c.to_s
                    if $grid[r+i][c] == nil
                        # puts " is empty"
                        # if block directly below is empty, update new row to move to
                        new_r = r + i
                    else
                        # puts " is not empty"
                        break
                    end
                end
                if new_r != -1
                    # puts "new_r was updated"
                    $grid[new_r][c] = $grid[r][c]
                    $grid[r][c] = nil
                    $valid_move = true
                    if new_r < $l - 1 && $grid[new_r+1][c] == $grid[new_r][c]
                        # puts "Can combine"
                        $grid[new_r+1][c] *= 2
                        $grid[new_r][c] = nil
                    end
                elsif r < $l - 1 && $grid[r+1][c] == $grid[r][c]
                    # puts "Can combine"
                    $grid[r+1][c] *= 2
                    $grid[r][c] = nil
                    $valid_move = true
                    # display()
                end
            end
        end
    end
end

def right
    for r in 0...$l
        for c in ($l-2).downto(0)
            if $grid[r][c] != nil
                # puts "Cell: " + r.to_s + ", " + c.to_s
                # if cell right is empty, shift right
                new_c = -1
                for i in 1...($l-c)
                    # print "Cell right: " + r.to_s + ", " + (c+i).to_s
                    if $grid[r][c+i] == nil
                        # puts " is empty"
                        # if block immediately right is empty, update new col to move to
                        new_c = c + i
                    else
                        # puts " is not empty"
                        break
                    end
                end
                if new_c != -1
                    # puts "new_c was updated"
                    $grid[r][new_c] = $grid[r][c]
                    $grid[r][c] = nil
                    $valid_move = true
                    if new_c < $l - 1 && $grid[r][new_c+1] == $grid[r][new_c]
                        # puts "Can combine after updating"
                        $grid[r][new_c+1] *= 2
                        $grid[r][new_c] = nil
                    end
                elsif c < $l - 1 && $grid[r][c+1] == $grid[r][c]
                    # puts "Can combine"
                    $grid[r][c+1] *= 2
                    $grid[r][c] = nil
                    $valid_move = true
                    # display()
                end
            end
        end
    end
end

def left
    for r in 0...$l
        for c in 1...$l
            if $grid[r][c] != nil
                # puts "Cell: " + r.to_s + ", " + c.to_s
                # if cell to the left is empty, shift left
                new_c = -1
                for i in 1..c
                    # print "Cell left: " + r.to_s + ", " + (c-i).to_s
                    if $grid[r][c-i] == nil
                        # puts " is empty"
                        # if block immediately left is empty, update new row to move to
                        new_c = c - i
                    else
                        # puts " is not empty"
                        break
                    end
                end
                if new_c != -1
                    # puts "new_c was updated"
                    $grid[r][new_c] = $grid[r][c]
                    $grid[r][c] = nil
                    $valid_move = true
                    if new_c > 0 && $grid[r][new_c-1] == $grid[r][new_c]
                        # puts "Can combine"
                        $grid[r][new_c-1] *= 2
                        $grid[r][new_c] = nil
                        # display()
                    end
                elsif c > 0 && $grid[r][c-1] == $grid[r][c]
                    # puts "Can combine"
                    $grid[r][c-1] *= 2
                    $grid[r][c] = nil
                    $valid_move = true
                    # display()
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
            for k in 0...req_space
                print "-"
            end
        end
        puts
        print "|"
        for j in 0...$l
            v = $grid[i][j]
            if v == nil
                v = ""
                for k in 0...req_space
                    v += " "
                end
            end
            v = v.to_s
            for k in 0...(req_space-v.length)
                print " "
            end
            print v.to_s + "|"
        end
        puts
    end
    for j in 0...$l
        print " "
        for k in 0...req_space
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
    puts "New block"
    rand_r = nil
    rand_c = nil
    if !full?()
        loop do
            rand_r = rand($l)
            rand_c = rand($l)
            break if $grid[rand_r][rand_c] == nil
        end
    end
    if rand() > 0.7
        $grid[rand_r][rand_c] = 4
    else
        $grid[rand_r][rand_c] = 2
    end
end

def game_over?
    # overly simplified
    for r in 0...$l
        for c in 0...$l
            v = $grid[r][c]
            if v != nil
                if r > 0 && v == $grid[r-1][c] \
                    || r < $l - 1 && v != $grid[r+1][c] \
                    || c > 0 && v == $grid[r][c-1] \
                    || c < $l - 1 && v != $grid[r][c+1]
                    return false
                end
            end
        end
    end
    return true
end

play()