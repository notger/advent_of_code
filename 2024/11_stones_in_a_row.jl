using DataStructures

example = "125 17"
puzzle = read("data/11.dat", String)


function parse_inp(inp::String)::DefaultDict{Int, Int}
    #=
    As per the instructions, we are not interested in the ordering, but only the number, 
    so no need to keep track of positions or individual stones.

    Hence, the data structure we are going for here are not stones, but a counter of stones.
    =#
    nums = [parse(Int, x.match) for x in eachmatch(r"\d+", inp)]
    d = DefaultDict{Int, Int}(0)
    for n in nums
        d[n] += 1
    end
    return d
end


function process_number(n::Int)::Vector{Int}
    # Process the weird rules given:
    if n == 0
        return Vector{Int}([1])
    elseif length(local s = string(n)) % 2 == 0
        mid = Int(length(s) / 2)
        return Vector{Int}([
            parse(Int, s[1:mid]), parse(Int, s[mid + 1:end])
        ])
    else
        return Vector{Int}([n * 2024])
    end
end


function step(puzzle::DefaultDict)::DefaultDict
    #= 
    For one step we are going to process each number in turn. All items with the same number result in the same new number,
    so the amount transfers over. E.g. If A with amount N becomes B, then you have N times the number B after blinking.

    Here, we opt for creating a new dictionary each run, as it can be that A -> B but there already are stones B in the set,
    so we would have to find a correct order to process every stone only once. We are saving us this hassle by sacrificing
    a bit of memory allocation time instead.
    =#
    output = DefaultDict{Int, Int}(0)

    for (num, amount) in puzzle
        new_nums = process_number(num)
        for new_num in new_nums
            output[new_num] += amount
        end
    end

    return output
end


function solve(puzzle::DefaultDict, N::Int)::Int
    #=
    Solving requires us to step through N times for both parts.
    =#
    for _ in range(1, N)
        puzzle = step(puzzle)
    end

    return sum(values(puzzle))
end


@time begin
    for (k, N) in enumerate([25, 75])
        println()
        println("Part $k: ", solve(parse_inp(example), N))
        println("Part $k: ", solve(parse_inp(puzzle), N))
    end
end