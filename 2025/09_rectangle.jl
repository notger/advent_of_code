const Point = NTuple{2, Int}
const Segment = NTuple{2, Point}

function parse_inp(lines)
    points = Vector{Point}(undef, length(lines))
    for (i, line) in pairs(lines)
        matches = collect(eachmatch(r"-?\d+", line))
        @assert length(matches) == 2
        points[i] = (parse(Int, matches[1].match), parse(Int, matches[2].match))
    end
    return points
end

function area(a::Point, b::Point)
    return (abs(b[1] - a[1]) + 1) * (abs(b[2] - a[2]) + 1)
end

function point_in_area(a::Point, b::Point, c::Point)
    left, right = minmax(a[1], b[1])
    lower, upper = minmax(a[2], b[2])
    return (left < c[1] < right) && (lower < c[2] < upper)
end

@assert point_in_area((1, 2), (10, 20), (5, 5))
@assert !point_in_area((1, 2), (10, 20), (5, 50))
@assert !point_in_area((1, 2), (10, 20), (1, 2))

function path_is_crossing(a::Point, b::Point, path::Segment)
    left, right = minmax(a[1], b[1])
    lower, upper = minmax(a[2], b[2])
    p1, p2 = path

    @assert (p1[1] == p2[1]) || (p1[2] == p2[2])

    if p1[1] == p2[1]
        x = p1[1]
        if x <= left || x >= right
            return false
        end

        y1, y2 = minmax(p1[2], p2[2])
        return max(y1, lower) < min(y2, upper)
    end

    y = p1[2]
    if y <= lower || y >= upper
        return false
    end

    x1, x2 = minmax(p1[1], p2[1])
    return max(x1, left) < min(x2, right)
end

@assert !path_is_crossing((1, 1), (10, 10), ((20, 20), (20, 30)))
@assert !path_is_crossing((5, 5), (10, 10), ((5, 1), (5, 15)))
@assert path_is_crossing((5, 5), (10, 10), ((6, 1), (6, 15)))
@assert path_is_crossing((5, 5), (10, 10), ((9, 1), (9, 15)))
@assert !path_is_crossing((5, 5), (10, 10), ((10, 1), (10, 8)))
@assert path_is_crossing((5, 5), (10, 10), ((3, 7), (13, 7)))
@assert path_is_crossing((5, 5), (10, 10), ((3, 7), (7, 7)))
@assert path_is_crossing((5, 5), (10, 10), ((6, 7), (8, 7)))

function all_paths_clear(a::Point, b::Point, paths)
    for path in paths
        if path_is_crossing(a, b, path)
            return false
        end
    end
    return true
end

function solve1(inp)
    return maximum(area(inp[i], inp[j]) for i in eachindex(inp) for j in (i + 1):length(inp))
end

function solve2(inp)
    res = 0
    paths = Segment[(inp[k - 1], inp[k]) for k in 2:length(inp)]
    push!(paths, (inp[end], inp[1]))

    for i in eachindex(inp)
        for j in (i + 1):length(inp)
            if all_paths_clear(inp[i], inp[j], paths)
                res = max(res, area(inp[i], inp[j]))
            end
        end
    end

    return res
end

example = parse_inp(readlines("data/09_example.dat"))
@assert solve1(example) == 50

function main()
    puzzle = parse_inp(readlines("data/09.dat"))

    println(solve2(example))

    @time begin
        println(solve1(puzzle))
        println(solve2(puzzle))
    end
end

main()
