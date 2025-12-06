import Base.parse

example_ranges, example_items = map(string, split("3-5
10-14
16-20
12-18

1
5
8
11
17
32", "\n\n"))
puzzle_ranges, puzzle_items = map(string, split(read("data/05.dat", String), "\n\n"))


function parse(ranges_inp, items_inp)
    range = [parse.(Int64, split(range, '-')) for range in split(ranges_inp, '\n')]
    items = parse.(Int64, split(items_inp, '\n'))
    return sort(range), sort(items)
end


function solve1(ranges_inp, items_inp)
    ranges, items = parse(ranges_inp, items_inp)

    k = 1
    res = 0
    for item in items
        if item < ranges[k][1]
            continue
        end

        # Go up until we hit a potential range
        while item > ranges[k][2] && k < length(ranges)
            k += 1
        end

        if ranges[k][1] <= item <= ranges[k][2]
            #println("$item falls in range $(ranges[k])")
            res += 1
        end
    end
    println(res)
    return res
end
@assert solve1(example_ranges, example_items) == 3


function consolidate_ranges(ranges)
    new_ranges = [ranges[1]]

    for range in ranges[2:1:end]
        # Is the beginning of the new range within the so far highest range?
        if range[1] <= new_ranges[end][2]
            if range[2] > new_ranges[end][2]
                new_ranges[end] = [new_ranges[end][1], range[2]]
            end
        else
            push!(new_ranges, range)
        end
    end
    return new_ranges
end
#ranges, items = parse(example_ranges, example_items)
#println(ranges, " -> ", consolidate_ranges(ranges))


function solve2(ranges_inp, items_inp)
    ranges, items = parse(ranges_inp, items_inp)
    res = 0

    for range in consolidate_ranges(ranges)
        res += range[2] - range[1] + 1
    end

    return res
end


@time begin
    println(solve1(puzzle_ranges, puzzle_items))
    println(solve2(puzzle_ranges, puzzle_items))
end