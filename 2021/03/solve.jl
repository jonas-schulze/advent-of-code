using Test

function bitmask(input)
    m = countlines(input)
    n = length(readline(input))
    mask = BitMatrix(undef, n, m)
    for (i, l) in enumerate(eachline(input))
        for (j, c) in enumerate(l)
            mask[j,i] = c == '1'
        end
    end
    return mask'
end

function power(input)
    mask = bitmask(input)
    m = size(mask, 1)
    γ₂ = vec(count(mask, dims=1) .> m÷2)
    reverse!(γ₂) # switch endianness
    ε₂ = map(!, γ₂)
    # convert to decimal:
    γ = evalpoly(2, γ₂)
    ε = evalpoly(2, ε₂)
    return γ*ε
end

@test power("test.txt") == 198
@show power("input.txt")
