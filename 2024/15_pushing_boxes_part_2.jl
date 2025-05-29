using DataStructures


example2 = "##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^"


function parse_inp(inp)
    grid, moves = split(inp, "\n\n")
    
    # Split into lines before doubling:
    grid = [double_symbols(line) for line in split(grid, "\n")]

    grid = [[c for c in line] for line in grid]

    return grid, get_robot(grid), moves
end


function double_symbols(line)
    line = replace(line, "#" => "##")
    line = replace(line, "." => "..")
    line = replace(line, "O" => "[]")
    line = replace(line, "@" => "@.")
    return line 
end


function get_robot(grid)
    for row in range(1, length(grid))
        for col in range(1, length(grid[1]))
            if grid[row][col] == '@'
                grid[row][col] == '.'
                return (row, col)
            end
        end
    end
end


# ============================== Direct array manipulation method =============================== #
# We will operate on the grid directly, as we did in part 1.


function try_move(grid, robot::Tuple{Int, Int}, direction::Char)
    x, y = robot
    if direction == '<'
        k = y - 1
        while grid[x][k] == ']'
            k -= 2
        end

        if grid[x][k] == '.'
            for i in range(k, y - 1)
                grid[x][i] = grid[x][i + 1]
            end
            robot = (x, y - 1)
        end

    elseif direction == '>'
        k = y + 1
        while grid[x][k] == '['
            k += 2
        end

        if grid[x][k] == '.'
            for i in range(k, y + 1, step=-1)
                grid[x][i] = grid[x][i - 1]
            end
            robot = (x, y + 1)
        end

    elseif direction == 'v'
        # Check the starting position of the queue:
        if grid[x + 1][y] == '['
            queue = OrderedSet([(x + 1, y), (x + 1, y + 1)])
        elseif grid[x + 1][y] == ']'
            queue = OrderedSet([(x + 1, y - 1), (x + 1, y)])
        elseif grid[x + 1][y] == '#'
            return grid, robot
        else
            robot = (x + 1, y)
            return grid, robot
        end
        row_wise_columns_to_move = DefaultDict(() -> Set())

        while length(queue) > 0
            (i, j) = popfirst!(queue)
            if grid[i][j] == ']'
                push!(queue, (i + 1, j - 1))
                push!(queue, (i + 1, j))
                push!(row_wise_columns_to_move[i], j)
                push!(row_wise_columns_to_move[i], j - 1)

            elseif grid[i][j] == '['
                push!(queue, (i + 1, j))
                push!(queue, (i + 1, j + 1))
                push!(row_wise_columns_to_move[i], j)
                push!(row_wise_columns_to_move[i], j + 1)

            elseif grid[i][j] == '.'
                push!(row_wise_columns_to_move[i], j)

            # If we do not encounter any of the above, we encounter a wall.
            # However, a wall means that none of the stack above can move, 
            # so we immediately return without changes.
            else
                return grid, robot
            end
        end

        # If we get here, then we did not encounter a wall, so we can move all items in our dict:
        for k in range(maximum(collect(keys(row_wise_columns_to_move))), x + 1, step=-1)
            for l in values(row_wise_columns_to_move[k])
                if l in values(row_wise_columns_to_move[k - 1])
                    grid[k][l] = grid[k - 1][l]
                else
                    grid[k][l] = '.'
                end
            end
        end
        robot = (x + 1, y)

    elseif direction == '^'
        if grid[x - 1][y] == '['
            queue = OrderedSet([(x - 1, y), (x - 1, y + 1)])
        elseif grid[x - 1][y] == ']'
            queue = OrderedSet([(x - 1, y - 1), (x - 1, y)])
        elseif grid[x - 1][y] == '#'
            return grid, robot
        else
            robot = (x - 1, y)
            return grid, robot
        end
        row_wise_columns_to_move = DefaultDict(() -> Set())

        while length(queue) > 0
            (i, j) = popfirst!(queue)
            if grid[i][j] == ']'
                push!(queue, (i - 1, j - 1))
                push!(queue, (i - 1, j))
                push!(row_wise_columns_to_move[i], j)
                push!(row_wise_columns_to_move[i], j - 1)

            elseif grid[i][j] == '['
                push!(queue, (i - 1, j))
                push!(queue, (i - 1, j + 1))
                push!(row_wise_columns_to_move[i], j)
                push!(row_wise_columns_to_move[i], j + 1)

            elseif grid[i][j] == '.'
                push!(row_wise_columns_to_move[i], j)

            else
                return grid, robot
            end
        end

        for k in range(minimum(collect(keys(row_wise_columns_to_move))), x - 1)
            for l in values(row_wise_columns_to_move[k])
                if l in values(row_wise_columns_to_move[k + 1])
                    grid[k][l] = grid[k + 1][l]
                else
                    grid[k][l] = '.'
                end
            end
        end
        robot = (x - 1, y)

    elseif direction == '\n'
        # Do nothing. We will return grid and robot unchanged.

    else
        println("ERROR: Invalid direction $direction received.")
    end

    return grid, robot
end


# ======================================== Object oriented method =========================== #
# Boxes and the robot will be mutable structs. This should be more readable code, easier to maintain.

function parse_boxes(grid)::Vector{Box}
    return [Box((i, j)) for i in range(1, length(grid)), j in range(1, length(grid[1])) if grid[i][j] == '[']
end


function parse_robot(pos)::Robot
    return Robot(pos)
end


function parse_walls(grid)::Vector{Wall}
    return [Wall((i, j)) for i in range(1, length(grid)), j in range(1, length(grid[1])) if grid[i][j] == '#']
end


function reparse_for_oo_approach(grid, robot)
    return parse_boxes(grid), parse_robot(robot), parse_walls(grid)
end


mutable struct Robot
    pos::Tuple{Int, Int}
end


mutable struct Wall
    pos::Tuple{Int, Int}
end


mutable struct Box
    left::Tuple{Int, Int}
end


function can_move(robot::Robot, boxes::Vector{Box}, walls::Vector{Wall}, direction::Char)::Bool
    new_pos = get_new_position(robot.pos, direction)
    
    downstream_boxes = [box for box in boxes if occupies(box, new_pos)]
    downstream_walls = [wall for wall in walls if occupies(wall, new_pos)]

    if length(downstream_walls) > 0  # We hit a wall.
        return false

    elseif length(downstream_boxes) == 0  # No more boxes in the way.
        move(robot, direction)
        return true

    elseif length(downstream_boxes) > 0 && all(can_move(box, boxes, walls, direction) for box in downstream_boxes)  # All boxes can be moved.
        move(robot, direction)
        return true

    else  # There are boxes in the way and not all of them can be moved.
        return false
    end

    # Default value, just because we don't trust ourselves.
    return false
end


function get_new_position(pos::Tuple{Int, Int}, direction::Char)::Tuple{Int, Int}
    x, y = pos
    if direction == '>'
        return x, y + 1
    elseif direction == '<'
        return x, y  - 1
    elseif direction == 'v'
        return x + 1, y
    else
        return x - 1, y
    end
end


function can_move(box::Box, boxes::Vector{Box}, walls::Vector{Wall}, direction::Char)::Bool
    # We will check whether we can move a given box. We will do this recursively and we will move the box when we find we can.
    new_left = get_new_position(box.left, direction)
    new_right = (new_left[1], new_left[2])

    downstream_boxes = [dbox for dbox in boxes if occupies(dbox, new_left) || occupies(dbox, new_right)]
    downstream_walls = [wall for wall in walls if occupies(wall, new_left) || occupies(wall, new_right)]

    if length(downstream_walls) > 0  # We hit a wall.
        return false

    elseif length(downstream_boxes) == 0  # No more boxes in the way.
        move(box, direction)
        return true

    elseif length(downstream_boxes) > 0 && all(can_move(dbox, boxes, walls, direction) for dbox in downstream_boxes)  # All boxes can be moved.
        move(box, direction)
        return true

    else  # There are boxes in the way and not all of them can be moved.
        return false
    end

    # Default value, just because we don't trust ourselves.
    return false
end


function occupies(box::Box, position::Tuple{Int, Int})::Bool
    right = (box.left[1], box.left[2] + 1)
    return position == box.left || position == right
end


function occupies(wall::Wall, position::Tuple{Int, Int})::Bool
    return position == wall.pos
end


function move(robot::Robot, direction::Char)::Robot
    robot.pos = get_new_position(robot.pos, direction)
    return robot 
end


function move(box::Box, direction::Char)::Box
    box.left = get_new_position(box.left, direction)
    return box
end


function score(box::Box)::Int
    return 100 * (box.left[1] - 1) + box.left[2] - 1
end


function score(boxes::Vector{Box})::Int
    return sum(score(box) for box in boxes)
end


# ======================================== General part ===================================== #


function print_grid(grid, robot)
    # Replace one element in the grid with the robot-indicator:
    x, y = robot
    grid[x][y] = '@'

    for line in grid
        println(join(line, ""))
    end

    # Reverse our replacement from above:
    grid[x][y] = '.'
end


function score(grid)::Int
    return sum(100 * (row - 1) + col - 1 for row in range(1, length(grid)), col in range(1, length(grid[1])) if grid[row][col] == '[')
end


function solve(inp)
    # We will implement both solutions here side by side to be able to compare them step by step and debug easier.
    # Ofc, by the point in time you are reading this, there is no debugging necessary. ;)
    grid, robot, moves = parse_inp(inp)
    boxes, robot2, walls = reparse_for_oo_approach(grid, robot)
    
    println()
    println("Grid at start:")
    print_grid(grid, robot)

    for (k, move) in enumerate(moves)
        #println()
        #println("After move $move in step $k, we have ...")
        grid, robot = try_move(grid, robot, move)
        #print_grid(grid, robot)

        can_move(robot2, boxes, walls, move)

        if score(grid) != score(boxes)
            println("Error in step $k!!!")
            break
        end
    end

    println()
    println("Grid after loop")
    print_grid(grid, robot)
    println()
    return score(grid)
end


@time begin
    println("Part 2, example: ", solve(example2))
    println("Part 2: ", solve(read("data/15.dat", String)))
end