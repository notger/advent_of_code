rules, queues = let
    lines = readlines("data/05.dat")

    rules_active = true
    r, q = Any[], Any[]
    for line in lines
        if length(line) == 0
            rules_active = false
            continue
        end

        if rules_active
            left, right = [parse(Int, x) for x in split(strip(line, '\n'), '|')]
            push!(r, (left, right))
        else
            push!(q, [parse(Int, x) for x in split(strip(line, '\n'), ',')])
        end
    end
    
    r, q
end


function score_queue(queue, rules)
    for (left, right) in rules
        if left in queue && right in queue
            lidx, ridx = findfirst(x->x == left, queue), findfirst(x->x == right, queue)
            if lidx >= ridx
                return 0
            end
        end
    end
    return queue[div((length(queue) - 1), 2) + 1]

    #= Alternative version which tries sub-lists. Definitely less readable but for shorter lists should be faster
    for k in range(2, length(queue))
        must_not_exist_left = queue[1:k-1]
        q = queue[k]
        if q in keys(rules)
            if rules[q] in must_not_exist_left
                return 0
            end
        end
    end
    return queue[div((length(queue) - 1), 2) + 1]
    =#
end


function order_pages(queue, rules)
    # Create the applicable, local rule set:
    applicable_rules = [(left, right) for (left, right) in rules if left in queue && right in queue]

    while score_queue(queue, rules) == 0
        for (left, right) in applicable_rules
            lidx, ridx = findfirst(x->x==left, queue), findfirst(x->x==right, queue)
            if lidx > ridx
                popat!(queue, ridx)
                insert!(queue, lidx, right)
            end
        end
    end

    return score_queue(queue, rules)
end


@time begin
    println("Part 1: ", sum([score_queue(queue, rules) for queue in queues]))
    println("Part 2: ", sum([order_pages(queue, rules) for queue in queues if score_queue(queue, rules) == 0]))
end
