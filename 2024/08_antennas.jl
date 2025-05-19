using DataStructures


# Load the puzzle data, making use of a DefaultDict:
antennas, xmax, ymax = let 
    lines = readlines("data/08.dat")
    
    grid = DefaultDict{Char, Array{Tuple{Int, Int}}}([])
    for (x, line) in enumerate(lines)
        for (y, c) in enumerate(line)
            if c ≠ '.'
                push!(grid[c], (x, y))
            end
        end
    end

    grid, length(lines), length(lines[1])
end


# Function to get the vector going from antenna A to antenna B:
function calc_dx(pos1::Tuple{Int, Int}, pos2::Tuple{Int, Int})::Tuple{Int, Int}
    return (pos2[1] - pos1[1], pos2[2] - pos1[2])
end


# We need a function to check whether we are still within bounds:
function is_within_grid(pos::Tuple{Int, Int})::Bool
    return (1 ≤ pos[1] ≤ xmax) && (1 ≤ pos[2] ≤ ymax)
end


# Have a function to find all resonance nodes for a given list of antennas:
function resonance_nodes(antenna_set::Array{Tuple{Int, Int}}, wavelength::Int)::Set{Tuple{Int, Int}}
    nodes = Set()
    for k in range(1, length(antenna_set) - 1)
        for l in range(k + 1, length(antenna_set))
            a, b = antenna_set[k], antenna_set[l]
            dx = calc_dx(a, b)
            res_a, res_b = (a[1] - dx[1], a[2] - dx[2]), (b[1] + dx[1], b[2] + dx[2])
            for (res_pot, dir) in [(res_a, -1), (res_b, 1)]
                w = 1
                while is_within_grid(res_pot) && w <= wavelength
                    push!(nodes, res_pot)
                    res_pot = (res_pot[1] + dir * dx[1], res_pot[2]  + dir * dx[2])
                    w += 1
                end
            end
        end
    end


    # Now, for a wavelength of greater than one we have also have to add all nodes which are part of an antenna which occurs at least twice.
    # It is cleaner to do this here, as otherwise we would have to have a wavelength-condition in the for-while-block above,
    # which reads rather nasty.
    if length(antenna_set) > 1 && wavelength > 1
        union!(nodes, antenna_set)
    end

    return nodes
end


function solve(antennas::DefaultDict{Char, Array{Tuple{Int, Int}}}, wavelength::Int)::Int
    resonances = Set{Tuple{Int, Int}}()
    for (_, antenna_set) in antennas
        union!(resonances, resonance_nodes(antenna_set, wavelength))
    end
    return length(resonances)
end


@time begin
    println("Part 1: ", solve(antennas, 1))
    println("Part 2: ", solve(antennas, 1_000_000))
end