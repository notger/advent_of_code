example = split("Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279", '\n')


mutable struct Game
    dxa::Int
    dya::Int
    dxb::Int
    dyb::Int
    zx::Int
    zy::Int
end  


function solve_game(game::Game)::Int
    #=
    We will solve a game by solving the linear equation A * na + B * nb = z
    while minimising cost = 3 * na + nb. But, there can be only one solution,
    so we need not worry about minimising.

    Actually, we can directly solve this equation system:
      | dxa * na + dxb * nb = zx
      | dya * na + dyb * nb = zy

      => na = 1 / dxa * (zx - dxb * nb)
      => nb = (zy - zx * dya / dxa) / (dyb - dxb * dya / dxa)
    =#
    dxa, dya, dxb, dyb, zx, zy = game.dxa, game.dya, game.dxb, game.dyb, game.zx, game.zy

    nb = Int(round((zy - zx * dya / dxa) / (dyb - dxb * dya / dxa)))
    na = Int(round((zx - dxb * nb) / dxa))

    # Check that we are actually hitting the target:
    tx = dxa * na + dxb * nb
    ty = dya * na + dyb * nb
    
    if abs(tx - zx) == 0 && abs(ty - zy) == 0
        return Int(round(3 * na + nb))
    else
        return 0
    end
end


function parse_inp(inp, offset=0)
    games = []

    a, b, z = Vector{Int}, Vector{Int}, Vector{Int}
    for line in inp
        if contains(line, "Button A")
            a = [parse(Int, x.match) for x in eachmatch(r"\d+", line)]
        elseif contains(line, "Button B")
            b = [parse(Int, x.match) for x in eachmatch(r"\d+", line)]
        elseif contains(line, "Prize")
            z = [parse(Int, x.match) for x in eachmatch(r"\d+", line)]
        elseif length(line) == 0
            push!(games, Game(a[1], a[2], b[1], b[2], z[1] + offset, z[2] + offset))
        end
    end
    push!(games, Game(a[1], a[2], b[1], b[2], z[1] + offset, z[2] + offset))
    return games
end


@time begin
    for (k, offset) in enumerate([0, 10000000000000])
        for (name, games) in [("example", parse_inp(example, offset)), ("puzzle", parse_inp(readlines("data/13.dat"), offset))]
            println("Part $k, $name: ", sum(solve_game(game) for game in games))
        end
        println()
    end
end