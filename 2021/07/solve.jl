using Test
using Statistics: median

function read_positions(file::String)
    str = read(file, String)
    snums = split(str, ',')
    pos = map(snums) do s
        parse(Int, s)
    end
end

fuel_consumption(pos, p) = fuel_consumption(identity, pos, p)

function fuel_consumption(f::Function, pos::Vector{Int}, p::Int)
    c = 0
    for x in pos
        c += f(abs(x-p))
    end
    c
end

function optimum1(file::String)
    pos = read_positions(file)
    m = median(pos)
    if isinteger(m)
        c = Int(m)
        f = fuel_consumption(pos, c)
        return c, f
    else
        _c = floor(Int, m)
        _C = ceil(Int, m)
        _f = fuel_consumption(pos, _c)
        _F = fuel_consumption(pos, _C)
        _f <= _F && return _c, _f
        return _C, _F
    end
end

# triangle numbers:
Δ(i) = i*(i+1)÷2

function optimum2(file::String)
    pos = read_positions(file)
    a, b = extrema(pos)
    c = a:b
    f = [fuel_consumption(Δ, pos, c) for c in a:b]
    i = argmin(f)
    return c[i], f[i]
end

@test optimum1("test.txt") == (2, 37)
@show optimum1("input.txt")

@test optimum2("test.txt") == (5, 168)
@show optimum2("input.txt")
