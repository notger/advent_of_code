example = "5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0"


function parse_input(inp::String)::Vector{Tuple{Int, Int}}
    lines = split(inp, "\n")

    broken = []

    for line in lines
        num1, num2 = [parse(Int, s.match) for s in eachmatch(r"\d+", line)]
        push!(broken, (num1 + 1, num2 + 1))  # Adjusting to 1-based indexing
    end

    return broken
end


function generate_admissible_points(size::Int = 71, broken::Vector{Tuple{Int, Int}} = Vector{Tuple{Int, Int}}())::Set{Tuple{Int, Int}}
    admissible = Set{Tuple{Int, Int}}()
    for i in range(1, size)
        for j in range(1, size)
            if (i, j) in broken
                continue
            else
                push!(admissible, (i, j))
            end
        end
    end
    return admissible
end


function find_path(start::Tuple{Int, Int}, target::Tuple{Int, Int}, admissible::Set{Tuple{Int, Int}})::Vector{Tuple{Int, Int}}
    #* Implements Dijkstra's algorithm on a set of admissible points. *#
    visited = Set{Tuple{Int, Int}}()
    queue = [(start, [start])]

    while !isempty(queue)
        current, path = popfirst!(queue)

        if current == target
            return path
        end

        if in(current, visited)
            continue
        end

        push!(visited, current)

        for dx in -1:1, dy in -1:1
            if abs(dx) + abs(dy) == 1  # Only consider orthogonal moves
                neighbor = (current[1] + dx, current[2] + dy)
                if in(neighbor, admissible) && !in(neighbor, visited)
                    new_path = copy(path)
                    push!(new_path, neighbor)
                    push!(queue, (neighbor, new_path))
                end
            end
        end
    end

    return []  # Return an empty path if no path is found
end


function print_grid(admissible::Set{Tuple{Int, Int}}, size::Int = 71, path::Vector{Tuple{Int, Int}}=Vector{Tuple{Int, Int}}())::Nothing
    for i in 1:size
        row = []
        for j in 1:size
            if in((i, j), admissible)
                if in((i, j), path)
                    push!(row, "O")
                else
                    push!(row, ".")
                end
            else
                push!(row, "#")
            end
        end
        println(join(row, ""))
    end
end


function solve1(input, grid_size::Int = 71, steps::Int = 1024, print::Bool = false)::Int
    broken = parse_input(input)
    admissible = generate_admissible_points(grid_size, broken[1:steps])
    path = find_path((1, 1), (grid_size, grid_size), admissible)

    if print
        print_grid(admissible, grid_size, path)
    end

    return length(path) - 1
end


function solve2(input, grid_size::Int = 71, steps_min::Int = 1024)::Tuple{Int, Int}
    broken = parse_input(input)
    path = find_path((1, 1), (grid_size, grid_size), generate_admissible_points(grid_size, broken[1:steps_min]))

    for k in range(steps_min, length(broken))
        # To speed up things, we will check if an added broken point is on the prior generated shortest path.
        # If it is not, we skip the regeneration of admissible points and the path search.
        # This speeds up the solution by a factor of 30.
        if k > steps_min && broken[k] in path
            admissible = generate_admissible_points(grid_size, broken[1:k])
            path = find_path((1, 1), (grid_size, grid_size), admissible)
        else
            continue
        end

        if isempty(path)
            return broken[k][1] - 1, broken[k][2] - 1  # Re-convert to 0-based indexing
        end
    end

    return (-1, -1)
end


@time begin
    println("Part 1 Example: ", solve1(example, 7, 12))
    println("Part 1 Puzzle: ", solve1(read("data/18.dat", String), 71, 1024, false))
    println()
    println("Please note that part 2 will be given in 0-indexed format.")
    println("Part 2 Example: ", solve2(example, 7, 12))
    println("Part 2 Puzzle: ", solve2(read("data/18.dat", String), 71, 1024))
end