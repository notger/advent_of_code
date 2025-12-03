example = split("11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124", ',')
dat = split(read("data/02.dat", String), ',')


function solve(inp)
    # More readable step-by-step version. For a fancipants-version, see below.
    res1 = 0
    res2 = 0

    for pair in inp
        left, right = map(x -> parse(Int, x), split(pair, '-'))

        # Apply the regex needed to solve each part separately, then check for empty sets before adding.
        # We will brute-force and go through all numbers.
        m1 = [parse(Int, m.match) for m in [match(r"^(\d+)\1$", string(k)) for k in range(left, right + 1)] if !isnothing(m)]
        m2 = [parse(Int, m.match) for m in [match(r"^(\d+)\1+$", string(k)) for k in range(left, right + 1)] if !isnothing(m)]
        if length(m1) > 0
            res1 += sum(m1)
        end

        if length(m2) > 0
            res2 += sum(m2)
        end
    end

    return res1, res2
end


function solve2(inp)
    # Less verbose, equally fast version to the solve above. Might lack readability. ;)
    pairs = [map(x -> parse(Int, x), split(pair, '-')) for pair in inp]

    res1 = sum([parse(Int, m.match) for (left, right) in pairs for m in [match(r"^(\d+)\1$", string(k)) for k in range(left, right + 1)] if !isnothing(m)])
    res2 = sum([parse(Int, m.match) for (left, right) in pairs for m in [match(r"^(\d+)\1+$", string(k)) for k in range(left, right + 1)] if !isnothing(m)])
    return res1, res2
end


@assert solve(example) == (1227775554, 4174379265)

@time begin
    println(solve(dat))
end