#=
Start of my journey to learn to code in Julia. Let's open a file and read the values, then store them in two lists:
=#
function read_input()
    puzzle = read("data/01.dat", String)
    lines = split(puzzle, '\n')
    
    #= This is a version with lists:
    l, r = Int[], Int[]
    for line in lines
        line = split(line)
        l = append!(l, parse(Int, line[1]))
        r = append!(r, parse(Int, line[2]))
    end
    =#

    # But we like arrays, if we know the length of the data already.
    # Interestingly, Vector{Int} is faster than zeros(length(lines)), but I guess that is b/c all values will be written twice.
    l, r = Vector{Int}(undef, length(lines)), Vector{Int}(undef, length(lines))
    for k in range(1, length(l))
        # Let's try a fancy thing and have local variables per loop run:
        let 
            line = split(lines[k])
            l[k], r[k] = parse(Int, line[1]), parse(Int, line[2]) 
        end
    end
    
    # The puzzle requires us the return the lists sorted for further processing:
    return sort(l), sort(r)
end


function part1(L, R)
    # Note that Julia normally does not apply functions element-wise, but with the dot-notation, it does so.
    # Alternatively, this would also have worked:
    # return sum(map(abs, L - R))
    return sum(abs.(L - R))
end

function part2(L, R)
    # Very cool built-in functions for getting a set from a list without having to declare it
    # and having a built in counter function which you give the argument and the comparer
    # to count the number of hits of the argument in the comparer.
    return sum([k * count(==(k), R) for k in unique(L)])
end


@time begin
    puzzle = read_input()
    println(part1(puzzle...))
    println(part2(puzzle...))
end