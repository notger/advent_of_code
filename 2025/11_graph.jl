using Memoization

function parse_inp(inp)
    d = Dict()
    for line in inp
        matches = [m.match for m in eachmatch(r"[a-z]+", line)]
        d[matches[1]] = [m for m in matches[2:end]]
    end
    return d
end
example = parse_inp(readlines("data/11_example.dat"))
example2 = parse_inp(readlines("data/11_example2.dat"))
puzzle = parse_inp(readlines("data/11.dat"))


function solve(inp, start="you", target="out")
    res = 0
    res_all = 0
    paths = [[p] for p in inp[start]]

    while length(paths) > 0
        path = pop!(paths)

        for next_stop in inp[path[end]]
            # No cycles, please.
            if next_stop in path
                continue
            end

            new_path = copy(path)
            if next_stop == target
                res += 1
            else
                push!(new_path, next_stop)
                push!(paths, new_path)
            end
        end
        #println("Paths has $(length(paths)) candidates, $res / $res_all.")
    end

    return res
end
@assert solve(example) == 5


@memoize function distance(a, b, net)
    if a == "out"
        return 0

    elseif b in net[a]
        return 1

    else
        return sum([distance(c, b, net) for c in net[a]])
    end
end
#@assert distance("you", "out", example) == 5
#@assert distance("svr", "out", example2) == 8


function solve2(net)
    return (
        distance("svr", "dac", net) * distance("dac", "fft", net) * distance("fft", "out", net) 
        + distance("svr", "fft", net) * distance("fft", "dac", net) * distance("dac", "out", net)
    )
end
@assert solve2(example2) == 2


@time begin
    println(solve(puzzle))
    println(solve2(puzzle))
end