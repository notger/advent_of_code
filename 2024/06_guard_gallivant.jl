example = split("....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...", '\n')


global next_direction = Dict(
    (-1, 0)=>(0, 1), (0, 1)=>(1, 0), (1, 0)=>(0, -1), (0, -1)=>(-1, 0)
)


function parse_input(inp)
    nrows, ncols = length(inp), length(inp[1])
    
    boxes, guard = Set{Tuple{Int, Int}}(), (0, 0)
    for row in range(1, nrows)
        for col in range(1, ncols)
            if inp[row][col] == '#'
                push!(boxes, (row, col))
            elseif inp[row][col] == '^'
                guard = (row, col)
            end
        end
    end
    
    return boxes, guard, nrows, ncols
end


function try_move(boxes, pos, dir)::Tuple{Tuple{Int, Int}, Tuple{Int, Int}}
    #=  This function moves the robot as long as it does not hit a box.
        It returns the new position and does not care whether that position
        is out of bounds. The calling code has to check for that.
        =#
    new_x, new_y = (x + y for (x, y) in zip(pos, dir))

    # Two cases: Either we can move, or we turn right:
    if (new_x, new_y) in boxes
        return pos, next_direction[dir]
    else
        return (new_x, new_y), dir
    end
end


function move(boxes, guard, nrows, ncols)::Int
    # Move the robot until it goes out of bounds OR begins to loop.
    visited = Set{Tuple{Int, Int, Int, Int}}()
    x, y = guard
    dx, dy = (-1, 0)

    while 1 ≤ x ≤ nrows && 1 ≤ y ≤ ncols
        push!(visited, (x, y, dx, dy))
        (x, y), (dx, dy) = try_move(boxes, (x, y), (dx, dy))

        # Check if we are in a loop. If so, return a special value of 0 to indicate that we got an infinite loop.
        if (x, y, dx, dy) in visited
            return 0
        end
    end

    distinct_positions = Set([(x, y) for (x, y, dx, dy) in visited])

    return length(distinct_positions)
end


function check_for_loops(boxes, guard, nrows, ncols)::Int
    return sum([1 for x in range(1, nrows), y in range(1, ncols) if move([boxes..., (x, y)], guard, nrows, ncols) == 0 ])
end


@time begin
    boxes, guard, nrows, ncols = parse_input(readlines("data/06.dat"))
    println("Part 1: ", move(boxes, guard, nrows, ncols))
    println("Part 2: ", check_for_loops(boxes, guard, nrows, ncols))
end