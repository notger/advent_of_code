using DataStructures
using ProgressBars
using Memoize


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


function get_cost_of_next_point(path::Vector{Tuple{Int, Int}}, next_point::Tuple{Int, Int}, starting_facing=(0, 1))::Int
    #=
    The cost is 1 for moving straight and 1001 for having to turn. We can calculate the moving-straight-vs-turning
    by checking the difference to the second to last position. If we are going across, then we are turning.

    The special case is the first move, where we do not have a second to last move, obviously. We will fake one here.
    =#
    reference = length(path) == 1 ? (path[end][1] - starting_facing[1], path[end][2] - starting_facing[2]) : (path[end-1][1], path[end-1][2])
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


# The current run-time of the solution is 15 minutes, which is egregiously long.
# A solution would be to memoize the following function properly and also have it be a greedy algo which breaks at the first solution.
# For this, we need to change the return value to single route (which will break a ton of code) and make it recursive.
# We could also think about introducing the orientation in the path-finding, like we did in the Python-version, but maybe that's not needed.
# Overall, this is a rework I am not willing to undertake right now.
function find_all_cheapest_paths(start, target, maze, starting_facing=(0, 1))
    current_cheapest_cost = length(maze) * 1000  # initial worst case estimate for the cost; everything above that will be automatically discarded

    candidates = PriorityQueue(Base.Order.Forward, [start] => 0)
    routes = []

    # We want to avoid running in circles. We will also go breadth-first, so any point reached will always be the cheapest we ever reached.
    # If we would not log these and do it differently, then from any given point of the path, we could start turning around and run back 
    # to the origin. Which would make this thing never finish.
    visited = Set()

    while length(candidates) > 0
        path, cost = dequeue_pair!(candidates)
        
        if cost >= current_cheapest_cost
            break
        end

        x0, y0 = path[end]
        next_points = [(x, y) for (x, y) in [(x0 + 1, y0), (x0 - 1, y0), (x0, y0 + 1), (x0, y0 - 1)] if (x, y) ∈ maze && (x, y) ∉ visited]

        for next_point in next_points
            new_path = vcat(path, [next_point])
            new_cost = cost + get_cost_of_next_point(path, next_point, starting_facing)

            # Only consider paths which are cheaper than the currently identified cheapest path:
            if new_cost > current_cheapest_cost
                continue
            end

            if next_point == target
                # If we have found a cheaper route, then we discard all old routes:
                if new_cost < current_cheapest_cost
                    current_cheapest_cost, routes = new_cost, []
                end                
                push!(routes, new_path)
            else
                push!(candidates, new_path => new_cost)
                push!(visited, next_point)
            end
        end
    end

    return current_cheapest_cost, routes
end


function solve(inp)::Tuple{Int, Int}
    #=
    This is a wrapper around the other function where we are going to check whether for all the points in the maze
    we can construct a path from that point to start and from that point to target for which the sum of the costs of
    both paths is equal to the cost of the cheapest path previously identified. If so, then that point is on a cheapest path.

    We just have to take care that the orientation of the first leg and the one of the second leg align so we do not have
    unwanted turns are heading off in the wrong direction. Due to how our search is set up, that might happen in some cases.
    =#
    start, target, maze = parse_inp(inp)
    cost, routes = find_all_cheapest_paths(start, target, maze)

    on_path = 0
    points_on_path = []

    for point in ProgressBar(maze)
        if point in Set(p for route in routes for p in route)
            on_path += 1
            push!(points_on_path, point)

        else
            first_leg_cost, first_leg_routes = find_all_cheapest_paths(start, point, maze)
            facing = first_leg_routes[1][end][1] - first_leg_routes[1][end-1][1], first_leg_routes[1][end][2] - first_leg_routes[1][end-1][2]
            second_leg_cost, _ = find_all_cheapest_paths(point, target, maze, facing)

            if first_leg_cost + second_leg_cost == cost
                on_path += 1
                push!(points_on_path, point)
            end
        end
    end

    print_maze(inp, [points_on_path])

    return cost, on_path
end


function print_maze(inp, paths)
    grid = [[c for c in line] for line in split(inp, "\n")]

    for path in paths
        for (x, y) in path
            if grid[x][y] == '.'
                grid[x][y] = 'O'
            end
        end
    end

    for line in grid
        println(join(line, ""))
    end
end


@time begin
    cost, on_path = solve(example)
    println("Part 1, example: Cost of $cost with $on_path points on the cheapest route.")
    println()

    cost, on_path = solve(read("data/16.dat", String))
    println("Part 1, puzzle: Cost of $cost with $on_path points on the cheapest route.")
end
