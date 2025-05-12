# Parse the data file:
begin
    puzzle = readlines("data/02.dat")

    puzzle = [[parse(Int, x) for x in split(line)] for line in puzzle]
end


function is_safe(report)
    d = abs.(diff(report))
    signs = sign.(diff(report))
    return all(signs.==signs[1]) && all(1 .<= d .<= 3)
end


function is_safe_with_repair(report)
    if is_safe(report)
        return true
    end

    for k in range(1, length(report))
        candidate = [report[i] for i in range(1, length(report)) if i != k]
        if is_safe(candidate)
            return true
        end
    end

    return false
end


@time begin
    println("Part 1: ", sum([is_safe(report) for report in puzzle]))
    println("Part 2: ", sum([is_safe_with_repair(report) for report in puzzle]))
end