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

function bingo(drawn, boards)
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
    return s, num, s*num
end

_drawn, _boards = load("test.txt")
drawn, boards = load("input.txt")

@test bingo(_drawn, _boards) == (188, 24, 4512)
@show bingo(drawn, boards)
