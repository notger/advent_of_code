# WARNING: Transscribed from a Python-version just to get a run-time.
# Prettified things while at it.
puzzle = readlines("data/01.dat")


function turn(start::Int64, code::String)::Tuple{Int64, Int64, Int64}
    target::Int64, zero_hits::Int64, cross_overs::Int64 = 0, 0, 0

    full_turns::Int64, rest::Int64, sign::Int64 = 0, 0, 0
    if length(code) > 3
        full_turns = parse(Int64, code[2:end - 2])
        rest = parse(Int64, code[end - 1:end])
    else
        full_turns = 0
        rest = parse(Int64, code[2:end])
    end

    if code[1] == 'R'
        sign = 1
    else
        sign = -1
    end

    cross_overs += full_turns
    target = start + sign * rest

    if target > 100
        target -= 100
        cross_overs += 1
    
    elseif target == 100
        target = 0
        zero_hits += 1

    elseif target < 0
        target += 100
        if start != 0
            cross_overs += 1
        end

    elseif target == 0
        zero_hits += 1
        if (start == 0) && (full_turns > 0)
            cross_overs -= 1
        end
    end

    return target, zero_hits, cross_overs
end
@assert turn(50, "R5") == (55, 0, 0)
@assert turn(50, "R55") == (5, 0, 1)
@assert turn(50, "R50") == (0, 1, 0)
@assert turn(50, "L55") == (95, 0, 1)
@assert turn(50, "L50") == (0, 1, 0)
@assert turn(50, "L250") == (0, 1, 2)
@assert turn(50, "R250") == (0, 1, 2)
@assert turn(40, "R12345") == (85, 0, 123)
@assert turn(0, "R10") == (10, 0, 0)
@assert turn(0, "L10") == (90, 0, 0)
@assert turn(0, "R310") == (10, 0, 3)
@assert turn(0, "L310") == (90, 0, 3)
@assert turn(0, "R300") == (0, 1, 2)
@assert turn(0, "L300") == (0, 1, 2)


function solve1(lines::Vector{String})
    start::Int64, hits::Int64, cross_overs::Int64 = 50, 0, 0
    res1::Int64, res2::Int64 = 0, 0
    for line in lines
        start, hits, cross_overs = turn(start, line)
        res1 += hits
        res2 += cross_overs
    end

    return res1, res1 + res2
end


@time begin
    println(solve1(puzzle))
end