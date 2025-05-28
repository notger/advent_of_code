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
    grid = [[c for c in line] for line in split(grid, "\n")]

    return grid, get_robot(grid), moves
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


function try_move(grid, robot::Tuple{Int, Int}, direction::Char)
    x, y = robot
    if direction == '<'
        k = y - 1
        while grid[x][k] == 'O'
            k -= 1
        end

        if grid[x][k] == '.'
            for i in range(k, y - 1)
                grid[x][i] = grid[x][i + 1]
            end
            robot = (x, y - 1)
        end

    elseif direction == '>'
        k = y + 1
        while grid[x][k] == 'O'
            k += 1
        end

        if grid[x][k] == '.'
            for i in range(k, y + 1, step=-1)
                grid[x][i] = grid[x][i - 1]
            end
            robot = (x, y + 1)
        end

    elseif direction == 'v'
        k = x + 1
        while grid[k][y] == 'O'
            k += 1
        end

        if grid[k][y] == '.'
            for i in range(k, x + 1, step=-1)
                grid[i][y] = grid[i - 1][y]
            end
            robot = (x + 1, y)
        end

    elseif direction == '^'
        k = x - 1
        while grid[k][y] == 'O'
            k -= 1
        end

        if grid[k][y] == '.'
            for i in range(k, x - 1)
                grid[i][y] = grid[i + 1][y]
            end
            robot = (x - 1, y)
        end

    elseif direction == '\n'
        # Do nothing.

    else
        println("ERROR: Invalid direction $direction received.")
    end

    return grid, robot
end


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
    return sum(100 * (row - 1) + col - 1 for row in range(1, length(grid)), col in range(1, length(grid[1])) if grid[row][col] == 'O')
end


function solve(inp)
    grid, robot, moves = parse_inp(inp)
    
    println()
    println("Grid at start:")
    print_grid(grid, robot)

    for move in moves
        grid, robot = try_move(grid, robot, move)
    end

    println()
    println("Grid after loop")
    print_grid(grid, robot)
    println()
    return score(grid)
end


@time begin
    println("Part 1: ", solve(read("data/15.dat", String)))
end