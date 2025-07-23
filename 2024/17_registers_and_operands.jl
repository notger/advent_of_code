# Not implemented yet. Had given Copilot a shot, but the transformation was very off.
function run(program, registers)
    a, b, c = 4, 5, 6
    pos = 1
    combo::Vector{Int128} = [1, 2, 3, registers...]
    res = Vector{Int128}()  # Resulting values to be returned.

    while pos < length(program)
    
        opcode, operand = program[pos], program[pos+1]
    
        if opcode == 0
            combo[a] = combo[a] >> combo[operand]
            pos += 2

        elseif opcode == 1
            combo[b] = combo[b] ⊻ operand  # bitwise XOR, alternative to xor(a, b)
            pos += 2

        elseif opcode == 2
            combo[b] = combo[operand] % 8

        elseif opcode == 3
            if combo[a] == 0
                pos += 2
            else
                pos = operand + 1
            end

        elseif opcode == 4
            combo[b] = combo[b] ⊻ combo[c]
            pos += 2

        elseif opcode == 5
            push!(res, combo[operand] % 8)
            pos += 2

        elseif opcode == 6
            combo[b] = combo[a] >> combo[operand]
            pos += 2

        elseif opcode == 7
            combo[c] = combo[a] >> combo[operand]
            pos += 2

        else
            error("Unknown opcode: $opcode")

        end
    end

    return res

end


@time begin
    println("Part 1, example: ", join(run([0, 1, 5, 4, 3, 0], [729, 0, 0]), ","))
    println("Part 2, puzzle: ", join(run([2, 4, 1, 7, 7, 5, 0, 3, 1, 7, 4, 1, 5, 5, 3, 0], [64012472, 0, 0]), ","))
    #* Not doing part 2 again, as I hated that last time. *#
end
