using Test, UnPack

struct SnailFishNumber
    level::Vector{Int}
    value::Vector{Int}
end

function Base.:(==)(s1::SnailFishNumber, s2::SnailFishNumber)
    s1.level == s2.level &&
    s1.value == s2.value
end

function read_snailfish_numbers(file)
    nums = SnailFishNumber[]
    for l in eachline(file)
        num = snailfish(l)
        push!(nums, num)
    end
    nums
end

function snailfish(s::String)
    # Maintain in-order traversal:
    level = Int[]
    value = Int[]
    cs = collect(s)
    l = 0
    i = 1
    while i <= length(cs)
        c = cs[i]
        if c == '['
            l += 1
        elseif c == ']'
            l -= 1
        elseif c in '0':'9'
            v = 0
            while true
                v *= 10
                v += c - '0'
                i += 1
                c = cs[i]
                c in '0':'9' || break
            end
            push!(level, l)
            push!(value, v)
            continue
        end
        i += 1
    end
    @assert l == 0
    @assert i == length(cs) + 1
    return SnailFishNumber(level, value)
end

snailfish(x::SnailFishNumber) = x
snailfish(x::Int) = SnailFishNumber([0], [x]) # intermediate
snailfish(v::Vector) = snailfish(v[1], v[2])

function snailfish(a, b)
    s1 = snailfish(a)
    s2 = snailfish(b)
    level = vcat(s1.level, s2.level)
    level .+= 1
    value = vcat(s1.value, s2.value)
    return SnailFishNumber(level, value)
end

@test snailfish([9,[8,7]]) == snailfish("[9,[8,7]]") == SnailFishNumber([1,2,2], [9,8,7])

function explode!(x::SnailFishNumber)
    @unpack level, value = x
    n = length(level)
    for i in 1:n-1
        l = level[i]
        l == level[i+1] || continue
        l > 4 || continue
        i > 1   && (value[i-1] += value[i])
        i < n-1 && (value[i+2] += value[i+1])
        level[i] -= 1
        value[i] = 0
        deleteat!(level, i+1)
        deleteat!(value, i+1)
        return true
    end
    return false
end

_xs = [
    snailfish([[[[[9,8],1],2],3],4]),
    snailfish([7,[6,[5,[4,[3,2]]]]]),
    snailfish([[6,[5,[4,[3,2]]]],1]),
    snailfish([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]),
    snailfish([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]),
]

_ys = [
    snailfish([[[[0,9],2],3],4]),
    snailfish([7,[6,[5,[7,0]]]]),
    snailfish([[6,[5,[7,0]]],3]),
    snailfish([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]),
    snailfish([[3,[2,[8,0]]],[9,[5,[7,0]]]]),
]

@testset "explode!" begin
    @testset "$x" for (x, y) in zip(_xs, _ys)
        @test x != y
        @test explode!(x)
        @test x == y
    end
end

function split!(x::SnailFishNumber)
    @unpack level, value = x
    for i in eachindex(value)
        v = value[i]
        v >= 10 || continue
        # Split value by overwriting current position and then inserting
        # between current and previous position.
        w = v ÷ 2
        value[i] = v - w
        insert!(value, i, w)
        l = level[i] += 1
        insert!(level, i, l)
        return true
    end
    return false
end

function reduce!(x::SnailFishNumber)
    explode!(x) || split!(x) || return false
    while true
        explode!(x) && continue
        split!(x) && continue
        return true
    end
end

function Base.:(+)(a::SnailFishNumber, b::SnailFishNumber)
    x = snailfish(a, b)
    reduce!(x)
    return x
end

@testset "reduce!" begin
    a = [[[[4,3],4],4],[7,[[8,4],9]]]
    b = [1,1]
    x = snailfish([a, b])
    y = snailfish([[[[0,7],4],[[7,8],[6,0]]],[8,1]])
    @test x != y
    @test reduce!(x)
    @test x == y
    @test snailfish(a) + snailfish(b) == y
end

# Construct Leaf Tree from given in-order traversal:
function treemap(f, ::Type{T}, x::SnailFishNumber) where {T}
    l = copy(x.level)
    v = T[v for v in x.value]
    while length(v) > 1
        _len = length(v)
        for i in 1:length(l)-1
            l[i] == l[i+1] || continue
            l[i] -= 1
            v[i] = f(v[i], v[i+1])
            deleteat!(l, i+1)
            deleteat!(v, i+1)
            break
        end
        @assert length(v) < _len
    end
    first(v)
end

tree(x::SnailFishNumber) = treemap(Any, x) do a, b
    Any[a, b]
end

magnitude(x) = treemap(Int, x) do a, b
    3a + 2b
end

test = read_snailfish_numbers("test.txt")
stest = snailfish([[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]])
@test sum(test) == stest
@test magnitude(stest) == 4140
@test maximum(magnitude(x + y) for x in test, y in test) == 3993

input = read_snailfish_numbers("input.txt")
@show magnitude(sum(input))
@show maximum(magnitude(x + y) for x in input, y in input)
