puzzle = read("data/03.dat", String)


function calculate_term(term)
    numbers = [parse(Int, s.match) for s in eachmatch(r"\d+", term)]
    return numbers[1] * numbers[2]
end

function solve2(matches)
    res, factor = 0, 1
    for term in matches
        if term == "do()"
            factor = 1
            continue
        end
        if term == "don't()"
            factor = 0
            continue
        end

        res += factor * calculate_term(term)
    end
    return res
end

@time begin
    matches = [s.match for s in eachmatch(r"(mul\(\d+,\d+\))", puzzle)]
    println("Part 1: ", sum(calculate_term(term) for term in matches))

    matches = [s.match for s in eachmatch(r"(mul\(\d+,\d+\))|(do\(\))|(don't\(\))", puzzle)]
    println("Part 2: ", solve2(matches))
end