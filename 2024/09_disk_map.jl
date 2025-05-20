using DataStructures


# Define a chunk on the disk:
mutable struct Chunk
    type::String  # Can be "file" or "empty"
    size::Int
    id::Int
    Chunk(type, size, id) = new(type, size, id)
end

is_file(c::Chunk) = c.type == "file"

function fill_chunk_at(chunks::Vector{Chunk}, idx::Int)
    @assert chunks[idx].type == "empty"
    @assert chunks[end].type == "file"
    c1, c2 = chunks[idx], chunks[end]

    # If c2 will still exist after filling:
    if c2.size > c1.size
        # do
        c1.type = "file"
        c1.id = c2.id
        c2.size -= c1.size

    # If sizes match exactly
    elseif c2.size == c1.size
        c1.type = "file"
        c1.id = c2.id
        c2.type = "empty"

    # If c2 will not exist anymore, but c1 will be split up
    else
        # Add an empty chunk after c1. We have to do this first, as the following stuff is destructive.
        pos = findfirst(==(c1), chunks)
        insert!(chunks, pos + 1, Chunk("empty", c1.size - c2.size, -1))

        c1.type = "file"
        c1.id = c2.id
        c1.size = c2.size
        c2.type = "empty"
    end

    # Clean up the diskmap afterwards:
    while chunks[end].type == "empty"
        pop!(chunks)
    end

    return chunks
end


function try_move_chunk(diskmap::Vector{Chunk}, file_id::Int)::Vector{Chunk}
    # How big is the chunk in question?
    k, file = length(diskmap), nothing
    while k > 1
        if diskmap[k].id == file_id
            file = diskmap[k]
            break
        else
            k -= 1
        end
    end

    # Find the first free chunk big enough to host the chunk in question:
    for (l, chunk) in enumerate(diskmap)
        if l ≥ k
            break
        end

        if chunk.type == "empty"
            if chunk.size > file.size
                insert!(diskmap, l + 1, Chunk("empty", chunk.size - file.size, -1))

                chunk.type = "file"
                chunk.id = file.id
                chunk.size = file.size
                file.type = "empty"
                file.id = -1

                break

            elseif chunk.size == file.size
                chunk.type = "file"
                chunk.id = file.id
                file.type = "empty"
                file.id = -1

                break
            end
        end
    end

    # Concatenation of empty spaces is thankfully not needed.

    return diskmap
end


# Parse the puzzle's input:
function parse_input()
    diskmap = let 
        #inp = "2333133121414131402"
        inp = read("data/09.dat", String)

        file_id = 0
        diskmap = Vector{Chunk}()
        for (k, c) in enumerate(inp)
            if parse(Int, c) > 0
                size = parse(Int, c)
                if k % 2 > 0
                    push!(diskmap, Chunk("file", size, file_id))
                    file_id += 1
                else
                    push!(diskmap, Chunk("empty", size, -1))
                end
            end
        end

        diskmap
    end
    return diskmap
end


function checksum(diskmap::Vector{Chunk})
    # For some reason, a double comprehension did not work.
    s, k = 0, 0    
    for chunk in diskmap
        for _ in range(1, chunk.size)
            if chunk.id > 0
                s += k * chunk.id
            end
            k += 1
        end
    end
    return s
end


function print_diskmap(diskmap)
    s = Vector{Any}()
    for chunk in diskmap
        if chunk.type == "file"
            val = string(chunk.id)
        else
            val = "."
        end

        for _ in range(1, chunk.size)
            append!(s, val)
        end
    end

    println(join(s))
    return join(s)
end


function simple_defrag(diskmap)
    # Loop from the beginning and pull from the end until the empty space we want to fill until there is no more items to fill:
    idx = 1

    while idx <= length(diskmap)
        chunk = diskmap[idx]
        if !is_file(chunk)
            diskmap = fill_chunk_at(diskmap, idx)
        end
        idx += 1
    end
    
    return checksum(diskmap)
end


function proper_defrag(diskmap)
    highest_file_id = diskmap[end].id

    for file_id in range(start=highest_file_id, stop=1, step=-1)
        diskmap = try_move_chunk(diskmap, file_id)
    end
    

    return checksum(diskmap)
end


@time begin
    println("Part 1: ", simple_defrag(parse_input()))
    println("Part 2: ", proper_defrag(parse_input()))
end