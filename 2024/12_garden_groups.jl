example = split("RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE", '\n')
puzzle = readlines("data/12.dat")


function get_neighbours(point::Tuple{Int,Int}, admissible_points::Set{Tuple{Int,Int}})::Set{Tuple{Int,Int}}
    (x, y) = point
    return Set(
        [
            (x + dx, y + dy) for (dx, dy) in [(1, 0), (0, 1), (-1, 0), (0, -1)]
            if (x + dx, y + dy) in admissible_points
        ]
    )
end

@assert length(get_neighbours((2, 2), Set([(x, y) for x in range(1, 3), y in range(1, 3)]))) == 4
@assert length(get_neighbours((1, 1), Set([(x, y) for x in range(1, 3), y in range(1, 3)]))) == 2
@assert length((get_neighbours((2, 2), Set([(x, y) for x in range(1, 2), y in range(1, 3)])))) == 3
@assert length(get_neighbours((9, 9), Set([(x, y) for x in range(1, 3), y in range(1, 3)]))) == 0

function perimeter_length(area::Set{Tuple{Int,Int}})::Int
    # The perimeter of one point in the area is 4 minus the amount of neighbours you have:
    return sum(4 - length(get_neighbours(point, area)) for point in area)
end

@assert perimeter_length(Set([(x, y) for x in range(1, 3), y in range(1, 3)])) == 12  # Square
@assert perimeter_length(Set([(1, 1), (1, 2), (1, 3), (2, 2)])) == 10  # T-like piece
@assert perimeter_length(Set([(1, 1), (1, 2), (1, 3), (2, 3), (2, 4)])) == 12  # L-like piece

function num_corners(area::Set{Tuple{Int, Int}})::Int
    return sum(count_corners(point, area) for point in area)
end

function count_corners(point::Tuple{Int, Int}, area::Set{Tuple{Int, Int}})::Int
    #=
    We want to counter the corners on a given point in the area.

    There are two options:
    a) It is an outer corner. You have one of these, if the diagonal across is not set. 
       We will check for all diagonals around the point and then count how many are outside of the area.
    b) It is an inner corner. Here you have the diagonal set, but not the point between them.
       So you are looking for an L-shaped area around the point, where the middle point / kink of the L is in the area.
    =#
    x, y = point
    L, R, U, D = (x - 1, y), (x + 1, y), (x, y + 1), (x, y - 1)
    LU, RU, RD, LD = (x - 1, y + 1), (x + 1, y + 1), (x + 1, y - 1), (x - 1, y - 1)

    corners = 0
    # Outer corner: 
    for (n1, n2) in ((L, U), (U, R), (R, D), (D, L))
        if n1 ∉ area && n2 ∉ area
            corners += 1
        end
    end

    # Inner corner:
    for (n1, n2, n3) in ((L, U, LU), (U, R, RU), (R, D, RD), (D, L, LD))
        if n1 ∈ area && n2 ∈ area && n3 ∉ area
            corners += 1
        end
    end

    return corners
end

@assert count_corners((0, 0), Set([(0, 0), (0, 1), (1, 0), (1, 1)])) == 1
@assert count_corners((0, 0), Set([(0, 0), (0, 1), (1, 0), (1, 1)])) == 1
@assert count_corners((0, 0), Set([(0, 0)])) == 4
@assert count_corners((1, 1), Set([(0, 1), (1, 0), (1, 1)])) == 2


function parse_input(inp)
    touched = Set{Tuple{Int, Int}}() # Will contain a map of all points we have already touched.
    all_points = Set([(x, y) for x in range(1, length(inp)), y in range(1, length(inp[1]))])

    areas = Vector{Set{Tuple{Int, Int}}}()
    for (x, y) in all_points
        if (x, y) ∉ touched  
            # When we find a point which was not touched = marked as belonging to an area yet, we can start a new area.
            area_marker = inp[x][y]
            area = Set{Tuple{Int, Int}}()
            candidates = [(x, y)]

            # Check the candidate for the marker and if they fit, add their neighbours to be checked next.
            # This could certainly be made slightly more efficient by not adding invalid candidates to the list.
            while length(candidates) > 0
                candidate = pop!(candidates)

                if inp[candidate[1]][candidate[2]] == area_marker && candidate ∉ touched
                    push!(touched, candidate)
                    push!(area, candidate)
                    append!(candidates, get_neighbours(candidate, all_points))
                end
            end

            push!(areas, area)
        end
    end

    return areas
end


function fence_price(area::Set{Tuple{Int, Int}})::Tuple{Int, Int}
    # We are returning both fence prices here, the regular and the discounted one.
    return (perimeter_length(area) * length(area), num_corners(area) * length(area))
end


@time begin
    for (name, areas) in [("example", parse_input(example)), ("puzzle", parse_input(puzzle))]
        prices = [fence_price(area) for area in areas]
        for k in range(1, 2)
            println("Part $k, $name: ", sum(price[k] for price in prices))
        end
        println()
    end
end