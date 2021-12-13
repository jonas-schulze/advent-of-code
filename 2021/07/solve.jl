using Test
using Statistics: median

function read_positions(file::String)
    str = read(file, String)
    snums = split(str, ',')
    pos = map(snums) do s
        parse(Int, s)
    end
end

function fuel_consumption(pos::Vector{Int}, p::Int)
    c = 0
    for x in pos
        c += abs(x-p)
    end
    c
end

function optimum_pos_fuel(file::String)
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

@test optimum_pos_fuel("test.txt") == (2, 37)
@show optimum_pos_fuel("input.txt")
