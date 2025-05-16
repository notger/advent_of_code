example = "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"


function parse_input(inp)
    puzzle = Any[]
    for line in inp
        nums = [parse(Int, x.match) for x in eachmatch(r"\d+", line)]
        push!(puzzle, (nums[1], nums[2:end]))
    end
    return puzzle
end


function add(a, b)
    return a + b
end


function mult(a, b)
    return a * b
end


function concat(a, b)
    return parse(Int, "$a$b")
end
@assert concat(12, 67) == 1267


function dig(target::Int, current::Int, vals::Array{Int}, operator, use_concat=false)::Bool
    @debug "Calling for target $target with ($current, $vals, $operator)"
    # Ending condition for recursion: we have processed all values.
    # If not determine the new current value.
    if length(vals) == 0
        return target == current
    elseif length(vals) == 1
        return target == operator(current, vals[1])
    else
        current = operator(current, vals[1])
    end

    # Second ending condition is when our current value is above target.
    # We only see addition and multiplication, so our values can never shrink
    # and we have to sneak up on our target value from below.
    if current > target
        return false
    end

    # If no breaking condition is met, then go into recursion for both methods:
    return any(
        [
            dig(target, current, vals[2:end], add, use_concat),
            dig(target, current, vals[2:end], mult, use_concat),
            use_concat ? dig(target, current, vals[2:end], concat, use_concat) : false,
        ]
    )
end


function is_valid(line::Tuple{Int, Array{Int}}, use_concat::Bool=false)::Bool
    # The first call needs a bit of special treatment:
    target, current, vals = line[1], line[2][1], line[2][2:end]

    # Bit of a shame that we have to repeat this section of code and this could be
    # done better, but we aren't here for pretty code, are we?
    return any(
        [
            dig(target, current, vals, add, use_concat),
            dig(target, current, vals, mult, use_concat),
            use_concat ? dig(target, current, vals, concat, use_concat) : false
        ]
    )
end

# Test some stuff
@assert is_valid((190, [10, 19])) == true
@assert is_valid((3267, [81, 40, 27])) == true
@assert is_valid((3266, [81, 40, 27])) == false


@time begin
    puzzle = parse_input(readlines("data/07.dat"))
    println("Part 1: ", sum(line[1] for line in puzzle if is_valid(line)))
    println("Part 2: ", sum(line[1] for line in puzzle if is_valid(line, true)))
end