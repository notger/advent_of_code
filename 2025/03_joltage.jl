example = split("987654321111111
811111111111119
234234234234278
818181911112111", '\n')

puzzle = readlines("data/03.dat")

function find_joltage(line, num_digits)
    res = ""

    while num_digits > 0
        if length(line) > 1
            digit = maximum(chop(line, head=0, tail=num_digits-1))
            idx = findfirst(digit, line)
        else
            digit = line
            idx = 1
        end

        if idx < length(line)
            line = chop(line, head=idx, tail=0)
        end
        res *= digit
        num_digits -= 1
    end

    return parse(Int, res)
end

#=
println(find_joltage(example[1], 2))
println(find_joltage(example[2], 2))
println(find_joltage(example[3], 2))
println(find_joltage(example[4], 2))
=#


function solve(inp, num_digits)
    res = 0

    for line in inp
        res += find_joltage(line, num_digits)
    end

    return res
end

@assert solve(example, 2) == 357
@assert solve(example, 12) == 3121910778619

@time begin
    println(solve(puzzle, 2))
    println(solve(puzzle, 12))
end