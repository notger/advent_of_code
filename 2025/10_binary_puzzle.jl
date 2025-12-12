# WARNING: Probably the ugliest and least cleaned up code of this year. Read at your own peril.

function parse_inp(inp)
    out = []
    for line in inp
        elems = split(line)
        part1 = (length(elems[1][2:end-1]), sum([2^(k - 1) for k in range(1, length(elems[1]) - 2) if elems[1][k + 1] == '#']))
        part2 = [sum([2^parse(Int64, m.match) for m in eachmatch(r"\d+", elem)]) for elem in elems[2:end-1]]
        part3 = parse.(Int64, split(elems[end][2:end-1], ','))
        push!(out, (part1, part2, part3))
    end
    return out
end
example = parse_inp(readlines("data/10_example.dat"))
puzzle = parse_inp(readlines("data/10.dat"))


function find_minimum_candidate1(line)
    part1, part2, part3 = line
    L, target = part1

    candidates = Set([0])
    k = 1
    while true
        next_stage = Set()
        for candidate in candidates
            new_candidates = Set([candidate ⊻ switch for switch in part2])
            if target in new_candidates
                return k
            else
                union!(next_stage, new_candidates)
            end
        end
        k += 1
        candidates = next_stage
        #println("After stage $k for target $target, we have $(length(candidates)) candidates: $(sort([candidates]))")

        if k > 10
            println("XXXXXXXXXX Could not find solution for $target !")
            return -1
        end
    end
end
@assert find_minimum_candidate1(example[1]) == 2
@assert find_minimum_candidate1(example[2]) == 3
@assert find_minimum_candidate1(example[3]) == 2


function find_minimum_candidate2(line)
    part1, part2, part3 = line
    L, target = part1

    # We were a bit over-eager in converting the numbers before, so we have to fix our mistake in some place
    # and here seems a bad choice, but the quickest:
    part2 = [[(p2 >> (k - 1)) % 2 for k in range(1, L)] for p2 in part2]

    # Construct the matrix A such that A * p = y = part3, which contains the first elements of each part2
    # in the first row and so on.
    A = reduce(hcat, part2)
    p = inv(transpose(A) * A) * part3
    return round(sum(p))
end
@assert find_minimum_candidate2(example[1]) == 10
@assert find_minimum_candidate2(example[2]) == 12
@assert find_minimum_candidate2(example[3]) == 11


function solve1(inp)
    # Part 1 we do by brute-forcing, i.e. trial-and-error.
    return sum([find_minimum_candidate1(line) for line in inp])
end
@assert solve1(example) == 7


function solve2(inp)
    res = 0
    for k in range(1, length(inp))
        res += find_minimum_candidate2(inp[k])
        println("Solver 2 in step $k : $res")    
    end
    return res
    #return sum([find_minimum_candidate2(line) for line in inp])
end
@assert solve2(example) == 33


@time begin
    println(solve1(puzzle))
    println(solve2(puzzle))
end
