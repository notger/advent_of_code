function distance(a, b)
    return sum((b - a) .^ 2)
end


function parse_inp(inp)
    # We return a list of values, sorted by their distance to the origin, to make things easier.
    return [map(x -> parse.(Int64, x.match), eachmatch(r"\d+", line)) for line in inp]
    #return sort(
    #    [map(x -> parse.(Int64, x.match), eachmatch(r"\d+", line)) for line in inp],
    #    by= x -> distance(x, [0, 0, 0])
    #)
end
example = parse_inp(readlines("data/08_example.dat"))
puzzle = parse_inp(readlines("data/08.dat"))


function all_distances(junctions)
    # This function creates a list of all distances between all junctions 
    # and returns an ordered list of the format [distance, junction1, junction2],
    # which means that it refers to the order in which the junctions came in.
    return sort([[distance(junctions[i], junctions[j]), i, j] for i in range(1, length(junctions)) for j in range(i + 1, length(junctions))])
end


function solve(junctions, num_ctr=10)
    distances = all_distances(junctions)

    circuits = Set()  # Contains only circuits of more than one junction.
    encountered = Set() # Contains all junctions which are part of a circuit of more than one junction.

    # Walk through the sorted array of all distances and build the circuits.
    # We will consider either as many examples as specified or as many as we have,
    # until all junctions are accounted for and we have only one big circuit (part 2).
    for candidates in distances[1:min(num_ctr, length(distances))]
        d, i, j = candidates
        encountered_i = i in encountered
        encountered_j = j in encountered

        # If neither is part of a circuit, create a new circuit:
        if !encountered_i && !encountered_j
            push!(circuits, Set([i, j]))
        elseif encountered_i && encountered_j
            c_tmp = [c for c in circuits if (i in c) || (j in c)]
            if length(c_tmp) > 1
                union!(c_tmp[1], c_tmp[2])
                circuits = [c for c in circuits if c != c_tmp[2]]  # I am sure this can be done better.
            end
        # If i is already part of a circuit, then just add j
        elseif encountered_i
            for circuit in circuits
                if i in circuit
                    push!(circuit, j)
                    break
                end
            end
            #circuit = [c for c in circuits if i in c][1]
            #push!(circuit, j)
        # If j is already part of a circuit, then just add i
        elseif encountered_j
            for circuit in circuits
                if j in circuit
                    push!(circuit, i)
                    break
                end
            end
            #circuit = [c for c in circuits if j in c][1]
            #push!(circuit, i)
        # Otherwise check if there are two circles which can be fused.
        # But since we here technically do not have a new "lowest distance", we do not increase the counter.
        else
            error("Should never reach this.")
        end

        union!(encountered, Set([i, j]))

        if (length(circuits) == 1) && (length(encountered) == length(junctions))
            return junctions[i][1] * junctions[j][1]
        end
    end

    sizes = sort([length(c) for c in circuits], rev=true)

    return prod(sizes[1:3])
end

@time begin
    println(solve(puzzle, 1000))
    println(solve(puzzle, length(puzzle)^2))
end
