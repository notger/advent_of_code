using DataStructures

function parse_inp(inp)
    return [map(x -> parse.(Int64, x.match), eachmatch(r"\d+", line)) for line in inp]
end
example = parse_inp(readlines("data/09_example.dat"))
puzzle = parse_inp(readlines("data/09.dat"))


function area(a, b)
    return (abs(b[1] - a[1]) + 1) * (abs(b[2] - a[2]) + 1)
end


function point_in_area(a, b, c)
    left = minimum([a[1], b[1]])
    right = maximum([a[1], b[1]])
    up = minimum([a[2], b[2]])
    down = maximum([a[2], b[2]])
    return (left < c[1] < right) && (up < c[2] < down)
end
@assert point_in_area([1, 2], [10, 20], [5, 5])
@assert !point_in_area([1, 2], [10, 20], [5, 50])
@assert !point_in_area([1, 2], [10, 20], [1, 2])

#=
function points_on_circumference(a, b, inp)
    left = [a[1], sort([a[2], b[2]])]
    right = [b[1], sort([a[2], b[2]])]
    up = [sort([a[1], b[1]]), a[2]]
    down = [sort([a[1], b[1]]), b[2]]

    candidates = [
        c for c in inp 
        if 
            ((c[1] == left[1]) && (left[2][1] < c[2] < left[2][2])) ||
            ((c[1] == right[1]) && (right[2][1] < c[2] < right[2][2])) ||
            ((up[1][1] < c[1] < up[1][2]) && (c[2] == up[2])) ||
            ((down[1][1] < c[1] < down[1][2]) && (c[2] == down[2]))
    ]

    return length([c for c in candidates if Set(c) != Set(a) && Set(c) != Set(b)]) > 0
end
@assert !points_on_circumference([7, 3], [11, 1], example)
@assert points_on_circumference([2, 3], [9, 7], example)
@assert points_on_circumference([11, 1], [2, 3], example)
@assert !points_on_circumference([9, 5], [2, 3], example)
=#


function path_is_crossing(a, b, path)
    # Is the path horizontal or vertical?
    lower, upper = sort([a[2], b[2]])
    left, right = sort([a[1], b[1]])

    if path[1][1] == path[2][1]  # vertical, i.e. stable along the first coordinate
        # We can not cross if the path is parallel to one of the sides.
        if (path[1][1] <= left) || (path[1][1] >= right)
            return false
        end

        # For the path to cross, we need to either start outside and end on the other side
        # or have one of the points in between.
        y1, y2 = sort([path[1][2], path[2][2]])
        if (y1 < lower && y2 > lower) || (y1 < upper && y2 > upper)  # lower or upper is crossed
            return true
        elseif y1 == lower && y2 == upper  # bisection
            return true
        elseif (lower < y1 < upper) || (lower < y2 < upper)  # both points within the rectangle
            return true
        end

    else  # horizontal path, i.e. stable along the second coordinate
        if (path[1][2] <= lower) || (path[1][2] >= upper)
            return false
        end

        x1, x2 = sort([path[1][1], path[2][1]])
        if (x1 < left && x2 > left) || (x1 < left && x2 > right)
            return true
        elseif x1 == left && x2 == right
            return true
        elseif (left < x1 < right) || (left < x2 < right)
            return true
        end
    end

    return false
end
@assert !path_is_crossing([1, 1], [10, 10], [[20, 20], [20, 30]])
@assert !path_is_crossing([5, 5], [10, 10], [[5, 1], [5, 15]])
@assert path_is_crossing([5, 5], [10, 10], [[6, 1], [6, 15]])
@assert path_is_crossing([5, 5], [10, 10], [[9, 1], [9, 15]])
@assert !path_is_crossing([5, 5], [10, 10], [[10, 1], [10, 8]])
@assert path_is_crossing([5, 5], [10, 10], [[3, 7], [13, 7]])
@assert path_is_crossing([5, 5], [10, 10], [[3, 7], [7, 7]])
@assert path_is_crossing([5, 5], [10, 10], [[6, 7], [8, 7]])


function all_paths_clear(a, b, paths)
    for path in paths
        if path_is_crossing(a, b, path)
            return false
        end
    end
    return true
end


function solve1(inp)
    return maximum([area(inp[i], inp[j]) for i in range(1, length(inp)) for j in range(i + 1, length(inp))])
end
@assert solve1(example) == 50


function solve2(inp)
    # The idea we are following: The largest rectangle must be one, which does not have any other
    # points which are inside the filled area, excluding the boundaries.
    res = 0
    # Create a list of paths
    paths = [[inp[k], inp[k - 1]] for k in range(2, length(inp))]
    push!(paths, [inp[1], inp[end]])

    for i in range(1, length(inp))
        for j in range(i + 1, length(inp))
            if all_paths_clear(inp[i], inp[j], paths)
                res = maximum([res, area(inp[i], inp[j])])
            end
        end
    end
    return res
end


println(solve2(example))

@time begin
    println(solve1(puzzle))
    println(solve2(puzzle))
end