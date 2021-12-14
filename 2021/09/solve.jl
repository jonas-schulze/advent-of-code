using Test

function read_heightmap(file)
    m = countlines(file)
    l = readline(file)
    n = length(l)
    h = Matrix{Int8}(undef, m, n)
    for (i, line) in enumerate(eachline(file))
        for (j, char) in enumerate(line)
            h[i,j] = Int8(char) - Int8('0')
        end
    end
    return h
end

function find_minimal_points(h)
    Is = CartesianIndex{2}[]
    for j in axes(h, 2), i in axes(h, 1)
        v = h[i, j]
        islow = true
        for Δi in (-1, 1)
            checkbounds(Bool, h, i+Δi, j) || continue
            @inbounds w = h[i+Δi, j]
            islow = v < w
            islow || break
        end
        islow || continue
        for Δj in (-1, 1)
            checkbounds(Bool, h, i, j+Δj) || continue
            @inbounds w = h[i, j+Δj]
            islow = v < w
            islow || break
        end
        islow || continue
        I = CartesianIndex(i, j)
        push!(Is, I)
    end
    return Is
end

function sum_risk_levels(file)
    h = read_heightmap(file)
    Is = find_minimal_points(h)
    minima = h[Is]
    return sum(minima) + length(minima)
end

function basin_size(h, I)
    Is = [I]
    basin = falses(size(h))
    basin[I] = true
    s = 1
    Δs = CartesianIndices((-1:2:1, 0:0)) ∪ CartesianIndices((0:0, -1:2:1))
    while !isempty(Is)
        I = pop!(Is)
        for Δ in Δs
            J = I + Δ
            checkbounds(Bool, h, J) || continue
            basin[J] && continue
            h[J] == 9 && continue
            push!(Is, J)
            basin[J] = true
            s += 1
        end
    end
    @assert count(basin) == s
    return s
end

function prod_largest_basins(file)
    h = read_heightmap(file)
    Is = find_minimal_points(h)
    s = [basin_size(h, I) for I in Is]
    sort!(s, rev=true)
    return prod(s[1:3])
end

@test sum_risk_levels("test.txt") == 15
@show sum_risk_levels("input.txt")

@test prod_largest_basins("test.txt") == 1134
@show prod_largest_basins("input.txt")
