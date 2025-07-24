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
            pos += 2

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


function shortened_step(A::Int128)::Int128
    return ((A % 8) ⊻ (A ÷ (2 ^ ((A % 8) ⊻ 7)))) % 8
end


function shortened_program(A::Int128)::Vector{Int128}
    # This is the shortened version of the program.
    # It is a transformation of the original program to a more compact form.
    # The transformation is based on the observation that the program
    # can be reduced to a single step that computes the result directly.
    output = Vector{Int128}(undef, 0)

    while A > 0
        out = shortened_step(A)
        A = A ÷ 8
        push!(output, out)
    end

    return output
end


function solve2(A0, i, target, generated_output)
    if i == length(target) + 1
        println("Found solution: ", A0 >> 3)
        return A0 >> 3
    end

    #println("Solving for A0 = $A0, i = $i, target = $(target[i]), generated_output = $generated_output")
    for k in range(0, 8)
        A = A0 + k
        out = shortened_step(A)
        #println("--- Iteration $i, step $k: A = $A, out = $out")
        if out == target[i]
            new_generated_output = copy(generated_output)
            push!(new_generated_output, out)
            #println("Match in iteration $i for k = $k: $A, generated_output: $new_generated_output; going to call with $(A << 3)")
            solve2(A << 3, i + 1, target, new_generated_output)
        end
    end

    #error("No solution found for A0 = $A0, i = $i, target = $target, generated_output = $generated_output")
end



@time begin
    println("Part 1, example: ", join(run([0, 1, 5, 4, 3, 0], [729, 0, 0]), ","))
    println("Part 1, puzzle: ", join(run([2, 4, 1, 7, 7, 5, 0, 3, 1, 7, 4, 1, 5, 5, 3, 0], [64012472, 0, 0]), ","))
    println("Part 1, puzzle, shortened: ", join(shortened_program(Int128(64012472)), ","))
    println()
    println("Part 2, puzzle: ", solve2(Int128(0), 1, [2, 4, 1, 7, 7, 5, 0, 3, 1, 7, 4, 1, 5, 5, 3, 0], []))
    #= 
        Note: Part 2 is unfinished, but I don't feel like bug-hunting again. Hated it last time. 
        The problem seems to be that we do not find a solution if we iterate for max 8 steps, but if
        we iterate for max 128 steps, we find a solution. However, that solution is lower than the
        correct solution, so something is definitely off.
        Not sure what, as the shortened programm seems to work correctly.
    =#
end

265652340990875
