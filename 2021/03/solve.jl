using Test

function bitmask(input)
    m = countlines(input)
    n = length(readline(input))
    mask = BitMatrix(undef, m, n)
    for (i, l) in enumerate(eachline(input))
        for (j, c) in enumerate(l)
            mask[i,j] = c == '1'
        end
    end
    return mask
end

function power(mask)
    m = size(mask, 1)
    γ₂ = vec(count(mask, dims=1) .> m÷2)
    reverse!(γ₂) # switch endianness
    ε₂ = map(!, γ₂)
    # convert to decimal:
    γ = evalpoly(2, γ₂)
    ε = evalpoly(2, ε₂)
    return γ, ε, γ*ε
end

function rating(R, data)
    m, n = size(data)
    mask = trues(m)
    for i in 1:n
        col = data[:,i]
        bit = R(count(col .& mask), m/2)
        mask .&= col .== bit
        m = count(mask)
        m == 1 && break
    end
    j = findfirst(mask)
    bin = reverse(data[j,:])
    dec = evalpoly(2, bin)
    return dec
end

function lifesupport(data)
    O2 = rating(>=, data)
    CO2 = rating(<, data)
    return O2, CO2, O2*CO2
end

test = bitmask("test.txt")
input = bitmask("input.txt")

@test power(test) == (22, 9, 198)
@show power(input)

@test lifesupport(test) == (23, 10, 230)
@show lifesupport(input)
