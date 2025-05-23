using DataStructures
using Base

example = split("p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3", '\n')


mutable struct Robot
    x::Int
    y::Int
    vx::Int
    vy::Int
    xmax::Int
    ymax::Int
end
function move(r::Robot)::Robot
    r.x += r.vx
    r.y += r.vy

    if r.x < 1
        r.x += r.xmax
    elseif r.x > r.xmax
        r.x -= r.xmax
    end

    if r.y < 1
        r.y += r.ymax
    elseif r.y > r.ymax
        r.y -= r.ymax
    end
    return r
end
function get_quadrant(r::Robot)::Int
    #= 
    This returns a quadrant number of 1 to 4, starting with the top left and going clockwise.
    If an item is on the center cross, we return the value 0.
    =#
    if r.x == r.xmax ÷ 2 + 1 || r.y == r.ymax ÷ 2 + 1
        return 0
    end

    # Maybe a lookup would be more efficient and elegant and readable and better?
    #=
    if r.x ≤ r.xmax ÷ 2
        if r.y ≤ r.ymax ÷ 2
            return 1
        else
            return 2
        end
    else
        if r.y ≤ r.ymax ÷ 2
            return 3
        else
            return 4
        end
    end
    =#

    is_up = r.x ≤ r.xmax ÷ 2
    is_left = r.y ≤ r.ymax ÷ 2

    lookup = Dict(
        [((true, true), 1), ((true, false), 2), ((false, true), 3), ((false, false), 4)]
    )

    return lookup[(is_up, is_left)]
end


function parse_inp(inp, xmax=7, ymax=11)::Vector{Robot}
    #=
    Please note that we want to stick to the convention that x = axis 1 = going down,
    so we have to switch the values during parsing.
    Also, the values given are zero-based and Julia works one-based, so we have to add the offset.
    =#
    robots = Vector{Robot}()
    for line in inp
        y, x, vy, vx = [parse(Int, x.match) for x in eachmatch(r"-?\d+", line)]
        push!(robots, Robot(x + 1, y + 1, vx, vy, xmax, ymax))
    end
    return robots
end


function step(robots::Vector{Robot}, N::Int)::Vector{Robot}
    for k in range(1, N)
        robots = [move(r) for r in robots]
    end
    return robots
end


function score(robots::Vector{Robot})::Int
    quadrantcounts = DefaultOrderedDict{Int, Int}(0)

    for robot in robots
        quadrantcounts[get_quadrant(robot)] += 1
    end

    return reduce(*, [x for (k, x) in quadrantcounts if k > 0])
end


function print_robots(robots)
    # Use responsibly!
    xmax, ymax = robots[1].xmax, robots[1].ymax

    s = [["." for _ in range(1, ymax)] for _ in range(1, xmax)]

    positions = DefaultDict{Tuple{Int, Int}, Int}(0)
    for robot in robots
        positions[(robot.x, robot.y)] += 1
    end

    for (k, v) in positions
        s[k[1]][k[2]] = string(v)
    end

    println(join([join(line) for line in s], "\n"))
end


@time begin
    # Part 1:
    robots = parse_inp(readlines("data/14.dat"), 103, 101)
    robots = step(robots, 100)
    println("Part 1: ", score(robots))

    # Part 2:
    #=
        This part relies on manual analysis.

        You first have to look through e.g. the first 100 robot moves to realise that there are vertical and horizontal patterns showing up.
        I found these for my data at step 12 for the horizontal pattern and index 35 for the vertical pattern.
        Consider e.g. the horizontal pattern, which means that every item is in a sorted position horizontally, but not vertically.
        That means whenever the robots did a full horizontal cycle, we would have another chance at matching the horizontal and the vertical pattern.
        A cycle for the horizontal pattern takes xmax steps.
    
        This means we are looking for an index where both cycles fall together.
    =#
    local robots = parse_inp(readlines("data/14.dat"), 103, 101)
    xmax, ymax = robots[1].xmax, robots[2].ymax
    for k in range(1, 100000)
        robots = step(robots, 1)
        if (k - 12) % xmax == 0 && (k - 35) % ymax == 0
            println("Part 2: ", k)
            print_robots(robots)
            break
        end
    end

end