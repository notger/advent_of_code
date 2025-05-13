puzzle = readlines("data/04.dat")  # Wow, those strings come in lines and fully indexable!


# Let's be fancy and do it with recursion. In this case, there is little advantage in doing that,
# but I need to get recursions down better, so why not ...
# Normally, we would create a search direction, get all points in that direction if they are in the grid
# and check if that makes for the word we search.
# A recursion would be great if the word can change directions, but that is not the case.
function search_for_next_letter(grid, s, x, y, dir = nothing)
    res = 0

    # If we already have a search direction, i.e. if we found the 'M' surrounding a 'X',
    # then we know the next (x, y). Otherwise we set it to nothing.
    if dir ≠ nothing
        x_new, y_new = x + dir[1], y + dir[2]
        is_inside_grid = 1 ≤ x_new ≤ length(grid) && 1 ≤ y_new ≤ length(grid[1])
    else
        x_new, y_new, is_inside_grid = nothing, nothing, nothing
    end

    # For more than one letter missing, we can not finish yet:
    if length(s) > 1
        c, s_new = s[1], s[2:end]
        
        #= Now if we are looking for the first letter == we don't have a direction yet,
        we will check all directions. Break-off criterion then is that we must not check 
        our starting point and we must not go out of bounds, but each point around our
        starting point which is a hit triggers another call, but this time with a known
        direction.=#
        if isnothing(x_new) && isnothing(y_new)
            for x_new in [x - 1, x, x + 1]
                for y_new in [y - 1, y, y + 1]
                    is_inside_grid = 1 ≤ x_new ≤ length(grid) && 1 ≤ y_new ≤ length(grid[1])
                    if (x_new, y_new) == (x, y) || !is_inside_grid
                        continue
                    end
                    if grid[x_new][y_new] == c
                        dir = (x_new - x, y_new - y)
                        res += search_for_next_letter(grid, s_new, x_new, y_new, dir)
                    end
                end
            end
        else
            # If x-new, y-new already existed because we knew the direction to search for, we can jump right into it:
            if is_inside_grid
                if grid[x_new][y_new] == c
                    res += search_for_next_letter(grid, s_new, x_new, y_new, dir)
                end
            end
        end

    else
        #= We are nearing the end where we are checking for the last letter.
        Two cases here:
          1) We are still inside the grid. Great, let's check whether we get the 'S'.
          2) We are out of bounds. Bummer, return 0.
        =#
        if is_inside_grid
            return grid[x_new][y_new] == s[1]
        else
            return 0
        end
    end

    return res

end


function search_for_x(grid, x, y, pattern)
    if grid[x][y] == 'A'
        corners = [(x + 1, y - 1), (x - 1, y - 1), (x - 1, y + 1), (x + 1, y + 1)]
        if all(1 ≤ new_coord[1] ≤ length(grid) && 1 ≤ new_coord[2] ≤ length(grid[1]) for new_coord in corners)
            corner_letters = join([grid[c[1]][c[2]] for c in corners])
            return corner_letters in pattern
        else
            return 0
        end
    else
        return 0
    end
end


@time begin
    # Part 1 is just a loop over all points invoking our search function:
    println("Part 1: ",
        sum(
            [
                search_for_next_letter(puzzle, "MAS", row, col) 
                for row in range(1, length(puzzle)), col in range(1, length(puzzle[1]))
                if puzzle[row][col] == 'X'
            ]
        )
    )

    #= In part 2, things change and we will now use a dumbed down approach where we are checking for the corners
    of a grid surrounding every "A" we can find. Two adjacent sides have to be "M", the other sides have to be "S".
    So we will be looking for "A", start with one corner and get the next corners clockwise. The pattern has to be
    either "MSSM" or "SSMM" or "SMMS" or "MMSS".=#
    corner_patterns = ["MSSM", "SSMM", "SMMS", "MMSS"]
    println("Part 2: ",
        sum(
            [
                search_for_x(puzzle, row, col, corner_patterns)
                for row in range(2, length(puzzle) - 1), col in range(2, length(puzzle[1]) - 1)
                if puzzle[row][col] == 'A'
            ]
        )
    )
end