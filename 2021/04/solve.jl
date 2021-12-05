using Test

_parse(n::AbstractString) = parse(Int, n)
_parse(v::Vector) = map(_parse, v)

function load(file)
    boards = Matrix{Int}[]
    local drawn
    # Read data from file:
    open(file) do io
        line = readline(io)
        nums = split(line, ',')
        drawn = _parse(nums)
        while !eof(io)
            blank = readline(io)
            @assert isempty(blank)
            board = zeros(Int, 5, 5)
            for i in 1:5
                line = readline(io)
                nums = split(line)
                # Read transposed board:
                board[:,i] = _parse(nums)
            end
            push!(boards, board)
        end
    end
    # Convert boards into compact storage:
    n = length(boards)
    cboards = Array{Int}(undef, 5, 5, n)
    for i in 1:n
        cboards[:,:,i] = boards[i]
    end
    return drawn, cboards
end

function first_bingo(drawn, boards)
    marked = falses(size(boards))
    n = size(boards, 3)
    rows = Array{Int}(undef, 5, 1, n)
    cols = Array{Int}(undef, 1, 5, n)
    local num, b
    for outer num in drawn
        ids = findall(==(num), boards)
        marked[ids] .= true
        # Check whether any board has won:
        count!(rows, marked)
        count!(cols, marked)
        fullrow = findfirst(==(5), rows)
        fullcol = findfirst(==(5), cols)
        fullrow === nothing && fullcol === nothing && continue
        # Find winning board:
        b1 = b2 = n
        fullrow === nothing || (b1 = fullrow[3])
        fullcol === nothing || (b2 = fullcol[3])
        b = min(b1, b2)
        break
    end
    board = boards[:,:,b]
    nomarks = map(!, marked[:,:,b])
    s = sum(board[nomarks])
    return b, num, s, s*num
end

function last_bingo(drawn, boards)
    @assert allunique(drawn)

    # Compute the round a respective field was marked:
    marked = zero(boards)
    local num, b
    for (i, num) in enumerate(drawn)
        ids = findall(==(num), boards)
        marked[ids] .= i
    end

    # Compute the round a respective board won:
    function round_filled(d, never)
        # Compute the round the last field of a respective row/col got marked,
        # or `never` if the row/col still has unmarked fields:
        notfull = minimum(marked, dims=d) .== 0
        round = maximum(marked, dims=d)
        round[notfull] .= never
        # Compute the round of the row/col of a board that was filled first:
        vec(minimum(round, dims=3-d))
    end
    never = length(drawn) + 1
    first_col_filled = round_filled(1, never)
    first_row_filled = round_filled(2, never)
    won = min.(first_col_filled, first_row_filled)

    # Check that all boards won eventually:
    @assert all(<(never), won)

    # Select board that won last and compute its score:
    round, b = findmax(won)
    board = boards[:,:,b]
    nomarks = marked[:,:,b] .> round
    s = sum(board[nomarks])
    num = drawn[round]
    return b, num, s, s*num
end

_drawn, _boards = load("test.txt")
drawn, boards = load("input.txt")

@test first_bingo(_drawn, _boards) == (3, 24, 188, 4512)
@show first_bingo(drawn, boards)

@test last_bingo(_drawn, _boards) == (2, 13, 148, 1924)
@show last_bingo(drawn, boards)
