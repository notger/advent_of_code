# This is a Copilot-generated solution which was not allowed to consult the web or prior implementations.
struct Chunks
    starts::Vector{Int}
    ends::Vector{Int}
    widths::Vector{Int}
    index_of::Dict{Int, Int}
end

function parse_points(path::String)
    points = Tuple{Int, Int}[]
    for line in eachline(path)
        stripped = strip(line)
        isempty(stripped) && continue
        x_text, y_text = split(stripped, ',')
        push!(points, (parse(Int, x_text), parse(Int, y_text)))
    end
    return points
end

function build_chunks(values::Vector{Int})
    sorted_values = sort!(unique(copy(values)))
    starts = Int[]
    ends = Int[]
    widths = Int[]
    index_of = Dict{Int, Int}()

    for i in eachindex(sorted_values)
        value = sorted_values[i]
        push!(starts, value)
        push!(ends, value)
        push!(widths, 1)
        index_of[value] = length(starts)

        if i < length(sorted_values)
            next_value = sorted_values[i + 1]
            if next_value > value + 1
                push!(starts, value + 1)
                push!(ends, next_value - 1)
                push!(widths, next_value - value - 1)
            end
        end
    end

    return Chunks(starts, ends, widths, index_of)
end

function mark_segment!(boundary::BitMatrix, fixed_index::Int, a::Int, b::Int, chunks::Chunks, vertical::Bool)
    lo = min(a, b)
    hi = max(a, b)

    for i in eachindex(chunks.starts)
        chunks.ends[i] < lo && continue
        chunks.starts[i] > hi && break
        if vertical
            boundary[fixed_index, i] = true
        else
            boundary[i, fixed_index] = true
        end
    end
end

function build_occupied(points::Vector{Tuple{Int, Int}})
    xs = [x for (x, _) in points]
    ys = [y for (_, y) in points]
    x_chunks = build_chunks(xs)
    y_chunks = build_chunks(ys)

    nx = length(x_chunks.starts)
    ny = length(y_chunks.starts)
    boundary = falses(nx, ny)

    for i in eachindex(points)
        x1, y1 = points[i]
        x2, y2 = points[mod1(i + 1, length(points))]
        if x1 == x2
            mark_segment!(boundary, x_chunks.index_of[x1], y1, y2, y_chunks, true)
        else
            mark_segment!(boundary, y_chunks.index_of[y1], x1, x2, x_chunks, false)
        end
    end

    visited = falses(nx + 2, ny + 2)
    queue_x = Int[1]
    queue_y = Int[1]
    visited[1, 1] = true
    head = 1

    while head <= length(queue_x)
        x = queue_x[head]
        y = queue_y[head]
        head += 1

        for (dx, dy) in ((1, 0), (-1, 0), (0, 1), (0, -1))
            nx2 = x + dx
            ny2 = y + dy
            if !(1 <= nx2 <= nx + 2 && 1 <= ny2 <= ny + 2)
                continue
            end
            if visited[nx2, ny2]
                continue
            end
            if 2 <= nx2 <= nx + 1 && 2 <= ny2 <= ny + 1 && boundary[nx2 - 1, ny2 - 1]
                continue
            end
            visited[nx2, ny2] = true
            push!(queue_x, nx2)
            push!(queue_y, ny2)
        end
    end

    occupied = boundary .| .!(@view visited[2:nx + 1, 2:ny + 1])
    return occupied, x_chunks, y_chunks
end

function prefix_counts(occupied::BitMatrix)
    nx, ny = size(occupied)
    prefix = zeros(Int, nx + 1, ny + 1)

    for x in 1:nx
        row_total = 0
        for y in 1:ny
            row_total += occupied[x, y]
            prefix[x + 1, y + 1] = prefix[x, y + 1] + row_total
        end
    end

    return prefix
end

function solve(path::String)
    points = parse_points(path)
    occupied, x_chunks, y_chunks = build_occupied(points)
    prefix = prefix_counts(occupied)

    part1 = 0
    part2 = 0

    for i in 1:length(points) - 1
        x1, y1 = points[i]
        xi1 = x_chunks.index_of[x1]
        yi1 = y_chunks.index_of[y1]

        for j in i + 1:length(points)
            x2, y2 = points[j]
            area = (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
            part1 = max(part1, area)

            xi2 = x_chunks.index_of[x2]
            yi2 = y_chunks.index_of[y2]
            lx = min(xi1, xi2)
            rx = max(xi1, xi2)
            by = min(yi1, yi2)
            ty = max(yi1, yi2)

            filled = prefix[rx + 1, ty + 1] - prefix[lx, ty + 1] - prefix[rx + 1, by] + prefix[lx, by]
            if filled == (rx - lx + 1) * (ty - by + 1)
                part2 = max(part2, area)
            end
        end
    end

    return part1, part2
end

function main()
    start_time = time_ns()

    for path in ("data/09_example.dat", "data/09.dat")
        part1, part2 = solve(path)
        println(path)
        println("part 1: ", part1)
        println("part 2: ", part2)
    end

    elapsed_ms = (time_ns() - start_time) / 1_000_000
    println("runtime_ms: ", round(elapsed_ms; digits = 3))
end

main()
