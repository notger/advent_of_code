using DataStructures

function parse_inp(inp)
    start = (1, findall(r"S", inp[1])[1][1])
    splitters = []
    for i in range(2, length(inp))
        append!(splitters, [(i, y[1]) for y in findall(r"\^", inp[i])])
    end
    return start, Set(splitters)
end
#example = parse_inp(readlines("data/07_example.dat"))
#puzzle = parse_inp(readlines("data/07.dat"))


mutable struct Beam 
    pos::Tuple{Int64,Int64}
    #path::Vector{Tuple{Int64, Int64}}
end


function move(beam::Beam)
    # In-place mutation of a beam, travelling downwards.
    beam.pos = (beam.pos[1] + 1, beam.pos[2])
end


function solve1(inp)
    num_rows = length(inp)
    start, splitters = parse_inp(inp)
    res = 0

    # We do this the easy way first: All beams move row-wise, so we will create a map of beams
    # in existence per row. We only need to track the current row and we only need to track the col of the beam.
    beams = [start[2]]

    for k in range(2, num_rows)
        new_beams = []
        for i in beams
            if (k, i) in splitters
                append!(new_beams, [i-1, i+1])
                res += 1
            else
                push!(new_beams, i)
            end
        end
        beams = Set(new_beams)
        #println("In line $k we have: $beams")
    end

    return res
end
@assert solve1(readlines("data/07_example.dat")) == 21


function solve2(inp)
    num_rows = length(inp)
    start, splitters = parse_inp(inp)

    # We do this the easy way first: All beams move row-wise, so we will create a map of beams
    # in existence per row. We only need to track the current row and we only need to track the col of the beam.
    beams = Dict(start[2]=>1)

    for k in range(2, num_rows)
        new_beams = DefaultDict(0)
        for i in keys(beams)
            if (k, i) in splitters
                new_beams[i-1] += beams[i]
                new_beams[i+1] += beams[i]
            else
                new_beams[i] += beams[i]
            end
        end
        beams = new_beams
        #println("In line $k we have: $beams")
    end

    return sum(values(beams))
end
@assert solve2(readlines("data/07_example.dat")) == 40


@time begin
    println(solve1(readlines("data/07.dat")))
    println(solve2(readlines("data/07.dat")))
end