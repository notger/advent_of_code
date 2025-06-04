using DataStructures


example = "###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############"


function parse_inp(inp::String)::Tuple{Tuple{Int, Int}, Tuple{Int, Int}, Set{Tuple{Int, Int}}}
    lines = split(inp, "\n")

    start, target = nothing, nothing
    maze = Set{Tuple{Int, Int}}()

    for (row, line) in enumerate(lines)
        for (col, c) in enumerate(line)
            if c == 'S'
                start = (row, col)
                push!(maze, (row, col))
            elseif c == 'E'
                target = (row, col)
                push!(maze, (row, col))
            elseif c == '.'
                push!(maze, (row, col))
            end
        end
    end

    return start, target, maze
end


function get_cost_of_next_point(path::Vector{Tuple{Int, Int}}, next_point::Tuple{Int, Int})::Int
    #=
    The cost is 1 for moving straight and 1001 for having to turn. We can calculate the moving-straight-vs-turning
    by checking the difference to the second to last position. If we are going across, then we are turning.

    The special case is the first move, where we do not have a second to last move, obviously. We will fake one here.
    =#
    reference = length(path) == 1 ? (path[end][1], path[end][2] - 1) : (path[end-1][1], path[end-1][2])
    dx1 = (next_point[1] - path[end][1], next_point[2] - path[end][2])
    dx2 = (path[end][1] - reference[1], path[end][2] - reference[2])
    return dx1 == dx2 ? 1 : 1001
end

@assert get_cost_of_next_point([(1, 0), (2, 0)], (3, 0)) == 1
@assert get_cost_of_next_point([(0, 1), (0, 2)], (0, 3)) == 1
@assert get_cost_of_next_point([(1, 0), (2, 0)], (2, 1)) == 1001
@assert get_cost_of_next_point([(1, 0), (2, 0)], (1, 0)) == 1001
@assert get_cost_of_next_point([(5, 5)], (5, 6)) == 1
@assert get_cost_of_next_point([(5, 5)], (5, 4)) == 1001
@assert get_cost_of_next_point([(5, 5)], (4, 5)) == 1001


function find_all_cheapest_paths(start, target, maze)
    current_cheapest_cost = length(maze) * 1001  # worst case estimate for the cost; everything above that will be automatically discarded

    candidates = PriorityQueue(Base.Order.Forward, [start] => 0)
    routes = []

    while length(candidates) > 0
        path, cost = dequeue_pair!(candidates)
        
        # Let's stop searching if our path is already above the currently cheapest cost. If we always pick the cheapest route, then this
        # means that all unfinished routes will be more expensive than our cheapest previous solution, so not eligible for winner.
        if cost >= current_cheapest_cost
            break
        end

        x0, y0 = path[end]
        next_points = [(x, y) for (x, y) in [(x0 + 1, y0), (x0 - 1, y0), (x0, y0 + 1), (x0, y0 - 1)] if (x, y) ∈ maze && (x, y) ∉ path]

        for next_point in next_points
            new_path = vcat(path, [next_point])
            new_cost = cost + get_cost_of_next_point(path, next_point)
            if next_point == target
                # If we have found a cheaper route, then we discard all old routes:
                if new_cost < current_cheapest_cost
                    current_cheapest_cost, routes = new_cost, []
                end
                push!(routes, new_path)
            else
                push!(candidates, new_path => new_cost)
            end
        end
    end
    return routes, current_cheapest_cost
end


@time begin
    routes, cost = find_all_cheapest_paths(parse_inp(example)...)
    println("Part 1, example: $cost")
    routes, cost = find_all_cheapest_paths(parse_inp(read("data/16.dat", String))...)
    println("Part 1, puzzle: $cost")
end
