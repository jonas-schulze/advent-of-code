using Test
using DataStructures

# grid will be transposed, but that doesn't matter
function read_grid(file)
    l = readline(file)
    n = length(l)
    m = countlines(file)
    grid = Matrix{Int8}(undef, m, n)
    i = 0
    for l in eachline(file)
        for c in l
            i += 1
            grid[i] = Int8(c) - Int8('0')
        end
    end
    grid
end

function dijkstra(grid)
    src = CartesianIndex(1, 1)
    dst = CartesianIndex(size(grid))

    # Possible directions:
    up = CartesianIndex(0, -1)
    down = CartesianIndex(0, 1)
    left = CartesianIndex(-1, 0)
    right = CartesianIndex(1, 0)

    # Keep track of distances from src to any other point:
    ∞ = typemax(Int)
    D = fill(∞, size(grid))
    D[src] = 0

    # Look for shortest path, ignore predecessors:
    Q = PriorityQueue(src => 0)
    while !isempty(Q)
        v = dequeue!(Q)
        v == dst && break
        for Δ in (up, down, left, right)
            w = v + Δ
            checkbounds(Bool, grid, w) || continue
            d = D[v] + grid[w]
            d < D[w] || continue
            Q[w] = D[w] = d
        end
    end

    return D[dst]
end

function repeat5(grid)
    m, n = size(grid)
    grid5 = similar(grid, 5m, 5n)
    # Repeat tiles:
    for i in 0:4, j in 0:4
        ti = i*m
        tj = j*n
        grid5[ti+1:ti+m,tj+1:tj+n] .= grid .+ (i + j)
    end
    # Wrap numbers greater than 9:
    for i in eachindex(grid5)
        @inbounds grid5[i] = mod1(grid5[i], 9)
    end
    return grid5
end

test = read_grid("test.txt")
test5 = repeat5(test)
@test dijkstra(test) == 40
@test dijkstra(test5) == 315

input = read_grid("input.txt")
input5 = repeat5(input)
@show dijkstra(input)
@show dijkstra(input5)
