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

mutable struct Box
    left::Tuple{Int, Int}
end

function can_move(box::Box, Boxes::Vector{Box})::Bool
    return false
end

function occupies(box::Box, position::Tuple{Int, Int})::Bool
    return false
end

function move(box::Box, direction::Char)::Box
    return Box
end

function score(box::Box)::Int
    return 0
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
    grid, robot, moves = parse_inp(inp)
    
    println()
    println("Grid at start:")
    print_grid(grid, robot)

    for (k, move) in enumerate(moves)
        #println()
        #println("After move $move in step $k, we have ...")
        grid, robot = try_move(grid, robot, move)
        #print_grid(grid, robot)
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