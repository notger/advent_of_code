function parse_inp(inp)
    blocks = split(inp, "\n\n")

    presents = Dict()
    for block in blocks[1:end-1]
        lines = split(block, '\n')
        key = parse(Int64, match(r"\d+", lines[1]).match)
        presents[key + 1] = lines[2:end]
    end

    areas = []
    for line in split(blocks[end], '\n')
        part1, part2 = split(line, ':')
        part1 = parse.(Int64, split(part1, 'x'))
        part2 = parse.(Int64, split(part2))
        push!(areas, (part1, part2))
    end

    return presents, areas
end
example_shapes, example_areas = parse_inp(read("data/12_example.dat", String))
puzzle_shapes, puzzle_areas = parse_inp(read("data/12.dat", String))


function fits_in(area::Vector{Int64}, block::Vector{Int64}, target::Vector{Int64})::Bool
    # How many blocks can we fit in?
    num_blocks = (area[1] ÷ block[1]) * (area[2] ÷ block[2])

    # Get the remainder of unallocated blocks:
    remainder = broadcast(-, target, num_blocks)

    # Are we done yet?
    if all(x <= 0 for x in remainder)
        return true
    end

    # How many blocks can we squeeze into the upper and lower bands?
    rest = broadcast(%, area, block)

    can_fit_stragglers = 0
    if rest[1] >= 3
        can_fit_stragglers += area[2] ÷ 3
    end
    if rest[2] >= 3
        can_fit_stragglers += area[1] ÷ 3
    end
    if rest[1] >= 3 && rest[2] >= 3
        can_fit_stragglers -= (rest[1] ÷ 3) * (rest[2] ÷ 3)
    end

    return can_fit_stragglers >= sum(remainder)
end
#println(fits_in(puzzle_areas[1][1], [7, 7], puzzle_areas[1][2]))


function solve(puzzle_areas)
    candidates = [[7, 7], [6, 8], [8, 6]]
    res = 0
    for (area_dim, target) in puzzle_areas
        if any(fits_in(area_dim, candidate, target) for candidate in candidates)
            res += 1
        end
    end
    return res
end
println(solve(puzzle_areas))