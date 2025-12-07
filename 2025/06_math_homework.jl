function parse_inp(inp)
    lines = [[parse.(Int64, m.match) for m in eachmatch(r"(\d+)", line)] for line in inp[1:1:end-1]]

    # Resort the lines:
    columns = [[lines[i][j] for i in range(1, length(lines))] for j in range(1, length(lines[1]))]

    return columns, split(inp[end])
end
nums, operators = parse_inp(readlines("data/06_example.dat"))

function solve(puzzle)
    nums, operators = puzzle
    res = 0

    for k in range(1, length(operators))
        if operators[k] == "+"
            res += sum(nums[k])
        else
            res += prod(nums[k])
        end
    end

    return res
end
@assert solve(parse_inp(readlines("data/06_example.dat"))) == 4277556


function parse_inp2(inp)
    inp_T = [[inp[i][j] for i in range(1, length(inp) - 1)] for j in range(1, length(inp[1]))]
    nums = [strip(join(a)) for a in inp_T]  # We now have a running list of all numbers as they are expected, with empty strings in between.

    # Re-sort the 1D-array into a matrix:
    cols = []
    running = []
    for item in nums
        if length(item) > 0
            push!(running, item)
        else
            push!(cols, running)
            running = []
        end
    end
    push!(cols, running)

    # Convert all strings to numbers:
    cols = map(x -> parse.(Int64, x), cols)

    return cols, split(inp[end])
end
@assert solve(parse_inp2(readlines("data/06_example.dat"))) == 3263827


@time begin
    println(solve(parse_inp(readlines("data/06.dat"))))
    println(solve(parse_inp2(readlines("data/06.dat"))))
end