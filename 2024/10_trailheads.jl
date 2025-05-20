inp = split("89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732", '\n')
inp = readlines("data/10.dat")
puzzle = [
    [parse(Int, c) for c in line] for line in inp
]


function get_neighbours(grid, pos::Tuple{Int, Int})::Vector{Tuple{Int, Int}}
    xmax, ymax = length(grid), length(grid[1])
    new_pos = [(pos[1] + dir[1], pos[2] + dir[2]) for dir in [(1, 0), (0, 1), (-1, 0), (0, -1)]]
    return [(x, y) for (x, y) in new_pos if 1 ≤ x ≤ xmax && 1 ≤ y ≤ ymax]
end


function walk_trail(grid, found, height, pos, part1=true)
    #= 
    This is a bit of an abomination, as I wanted to do it recursively this time (different to my python-solution).
    
    I accidentally programmed part 2 before part 1, then removed the "wrong" code to get part 1 right, realised that
    I should have kept the code and that I can put it all into one package.

    So what this recursive version now does is that it runs in two modes, determined by the flag part1.
    
    part1 mode works by changing a set and marking trail heads found and if it ever reaches the end
    while being at height 0, it gives back the number of elements in the set.

    part 2 mode works by simply returning the sum of all depth-first recursive calls which find a 9,
    thereby automatically returning all possible paths from a given trailhead to all targets.

    In both cases, the return value is the "score" of the trailhead.
    =#
    neighbours = [(x, y) for (x, y) in get_neighbours(grid, pos) if grid[x][y] == height + 1]

    if height == 8
        if part1 == true
            for n in neighbours
                push!(found, n)
            end

            return
        else
            return length(neighbours)
        end
    
    elseif length(neighbours) == 0
        if part1 == true
            return
        else
            return 0
        end
    
    else
        if part1 == true
            for (x, y) in neighbours
                walk_trail(grid, found, height + 1, (x, y), part1)
            end
        else
            return sum([walk_trail(grid, found, height + 1, (x, y), part1) for (x, y) in neighbours])
        end
    end

    if height == 0 && part1 == true
        return length(found)
    end
end


function solve(grid, part1=true)
    return sum([walk_trail(grid, Set(), 0, (x, y), part1) for x in range(1, length(grid)), y in range(1, length(grid[1])) if grid[x][y] == 0])
end


@time begin
    println("Part 1: ", solve(puzzle, true))
    println("Part 2: ", solve(puzzle, false))
end