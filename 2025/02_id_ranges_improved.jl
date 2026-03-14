const INPUT_PATH = "data/02.dat"

parse_range(token::AbstractString) = Tuple(parse.(Int, split(token, '-')))
parse_ranges(text::AbstractString) = parse_range.(split(chomp(text), ','))

const EXAMPLE = parse_ranges("11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124")

function repeat_block(block::Int, width::Int, repeats::Int)
    factor = 10^width
    value = 0
    for _ in 1:repeats
        value = value * factor + block
    end
    return value
end

function repeated_candidates(limit::Int; exact_twice::Bool = false)
    max_digits = ndigits(limit)
    candidates = Set{Int}()
    repeat_counts = exact_twice ? (2:2) : (2:max_digits)

    for repeats in repeat_counts
        max_width = max_digits ÷ repeats
        for width in 1:max_width
            lo = 10^(width - 1)
            hi = 10^width - 1
            for block in lo:hi
                value = repeat_block(block, width, repeats)
                value > limit && break
                push!(candidates, value)
            end
        end
    end

    return sort!(collect(candidates))
end

function prefix_sums(values::Vector{Int})
    sums = zeros(Int, length(values) + 1)
    for i in eachindex(values)
        sums[i + 1] = sums[i] + values[i]
    end
    return sums
end

function sum_in_ranges(candidates::Vector{Int}, sums::Vector{Int}, ranges)
    total = 0
    for (left, right) in ranges
        lo = searchsortedfirst(candidates, left)
        hi = searchsortedlast(candidates, right)
        total += sums[hi + 1] - sums[lo]
    end
    return total
end

function solve(ranges)
    limit = maximum(right for (_, right) in ranges)

    exact_twice = repeated_candidates(limit; exact_twice = true)
    repeated = repeated_candidates(limit)

    part1 = sum_in_ranges(exact_twice, prefix_sums(exact_twice), ranges)
    part2 = sum_in_ranges(repeated, prefix_sums(repeated), ranges)
    return part1, part2
end

function main()
    puzzle = parse_ranges(read(INPUT_PATH, String))
    println(solve(puzzle))
end

@assert solve(EXAMPLE) == (1227775554, 4174379265)

@time main()
