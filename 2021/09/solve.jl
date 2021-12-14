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

function find_minima(h)
    minima = similar(h, 0)
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
        push!(minima, v)
    end
    return minima
end

function sum_risk_levels(file)
    h = read_heightmap(file)
    minima = find_minima(h)
    return sum(minima) + length(minima)
end

@test sum_risk_levels("test.txt") == 15
@show sum_risk_levels("input.txt")
