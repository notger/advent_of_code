const TRACK_LENGTH = 100
const START_POSITION = 50
const INPUT_PATH = "data/01.dat"

function parse_move(code::AbstractString)
    direction = first(code)
    distance = parse(Int, code[2:end])
    return direction, distance
end

function displacement(direction::Char, distance::Int)
    direction == 'R' && return distance
    direction == 'L' && return -distance
    throw(ArgumentError("invalid direction: $direction"))
end

function directed_coordinate(position::Int, direction::Char)
    direction == 'R' && return position
    direction == 'L' && return -position
    throw(ArgumentError("invalid direction: $direction"))
end

arrival_position(position::Int, direction::Char, distance::Int) =
    mod(position + displacement(direction, distance), TRACK_LENGTH)

function seam_hits(position::Int, direction::Char, distance::Int)
    start = directed_coordinate(position, direction)
    finish = start + distance
    return fld(finish, TRACK_LENGTH) - fld(start, TRACK_LENGTH)
end

function apply_move(position::Int, code::AbstractString)
    direction, distance = parse_move(code)
    next_position = arrival_position(position, direction, distance)
    landed_on_zero = next_position == 0 ? 1 : 0
    pass_throughs = seam_hits(position, direction, distance) - landed_on_zero

    return next_position, landed_on_zero, pass_throughs
end

function solve(lines::AbstractVector{<:AbstractString})
    position = START_POSITION
    total_zero_hits = 0
    total_pass_throughs = 0

    for code in lines
        position, landed_on_zero, pass_throughs = apply_move(position, code)
        total_zero_hits += landed_on_zero
        total_pass_throughs += pass_throughs
    end

    return total_zero_hits, total_zero_hits + total_pass_throughs
end

for (position, code, expected) in [
    (50, "R5", (55, 0, 0)),
    (50, "R55", (5, 0, 1)),
    (50, "R50", (0, 1, 0)),
    (50, "L55", (95, 0, 1)),
    (50, "L50", (0, 1, 0)),
    (50, "L250", (0, 1, 2)),
    (50, "R250", (0, 1, 2)),
    (40, "R12345", (85, 0, 123)),
    (0, "R10", (10, 0, 0)),
    (0, "L10", (90, 0, 0)),
    (0, "R310", (10, 0, 3)),
    (0, "L310", (90, 0, 3)),
    (0, "R300", (0, 1, 2)),
    (0, "L300", (0, 1, 2)),
]
    @assert apply_move(position, code) == expected
end

@time begin
  println(solve(readlines(INPUT_PATH)))
end
