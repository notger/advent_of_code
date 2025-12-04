example = split("""..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.""", '\n')
puzzle = readlines("data/04.dat")


function parse_grid(inp)::Vector{Tuple{Int64, Int64}}
    num_rows, num_cols = length(inp), length(inp[1])
    return [(i, j) for i in range(1, num_rows) for j in range(1, num_cols) if inp[i][j] == '@']
end
test_grid = parse_grid(example)
num_rows, num_cols = length(example), length(example[1])


function surrounded_by_fewer_than(start::Tuple{Int64, Int64}, grid::Vector{Tuple{Int64, Int64}}, limit::Int64)::Bool
    x, y = start
    surrounding_boxes = [
        (x + dx, y + dy) 
        for dx in [-1, 0, 1] 
        for dy in [-1, 0, 1] 
        if ((dx, dy) !== (0, 0)) && ((x + dx, y + dy) in grid)
    ]
    return length(surrounding_boxes) < limit
end


function solve(inp)
    grid = parse_grid(inp)
    candidates = [candidate for candidate in grid if surrounded_by_fewer_than(candidate, grid, 4)]

    println(length(candidates))
    res = length(candidates)

    while length(candidates) > 0
        grid = [e for e in grid if !(e in candidates)]
        candidates = [candidate for candidate in grid if surrounded_by_fewer_than(candidate, grid, 4)]
        res += length(candidates)
    end
    println(res)
end

#@assert solve1(example) == 13


@time begin
    solve(puzzle)
end
