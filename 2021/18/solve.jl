using Test

struct SnailFishNumber
    a
    b
end

Base.show(io::IO, x::SnailFishNumber) = print(io, '[', x.a, ',', x.b, ']')

@test sprint(show, SnailFishNumber(SnailFishNumber(1, 2), 3)) == "[[1,2],3]"

function read_snailfish_numbers(file)
    nums = SnailFishNumber[]
    for l in eachline(file)
        num, tail = parse_snailfish(l)
        @assert tail == ""
        push!(nums, num)
    end
    nums
end

chars2int(cs) = foldl((n, c) -> 10n+(c-'0'), cs, init=0)

function parse_snailfish(s::AbstractString)
    if first(s) == '['
        t1 = SubString(s, 2)
        a, s1 = parse_snailfish(t1)
        @assert first(s1) == ','
        t2 = SubString(s1, 2)
        b, s2 = parse_snailfish(t2)
        @assert first(s2) == ']'
        t3 = SubString(s2, 2)
        return SnailFishNumber(a, b), t3
    else
        i = 0
        for c in s
            (c == ',' || c == ']') && break
            i += 1
        end
        n = chars2int(SubString(s, 1, i))
        t = SubString(s, i+1)
        return n, t
    end
end

snailfish(n::Int) = n
snailfish(v::Vector) = SnailFishNumber(snailfish(v[1]), snailfish(v[2]))
snailfish(s::String) = first(parse_snailfish(s))

@test snailfish([9,[8,7]]) == snailfish("[9,[8,7]]") == SnailFishNumber(9, SnailFishNumber(8, 7))

explode_addnext(x, ::Nothing) = x
explode_addnext(x::Int, v::Int) = x + v
explode_addnext(x::SnailFishNumber, v::Int) = SnailFishNumber(explode_addnext(x.a, v), x.b)

explode_addprev(x, ::Nothing) = x
explode_addprev(x::Int, v::Int) = x + v
explode_addprev(x::SnailFishNumber, v::Int) = SnailFishNumber(x.a, explode_addprev(x.b, v))

explode_snailfish(v::Vector) = explode_snailfish(snailfish(v))
explode_snailfish(x::Int, level::Int) = x, nothing
function explode_snailfish(x::SnailFishNumber, level::Int=1)
    # Check if this node needs to explode
    if level > 4 && x.a isa Int && x.b isa Int
        return 0, (x.a, x.b)
    end
    # Check if any of the children needs to explode
    a, expl = explode_snailfish(x.a, level+1)
    if expl != nothing
        prev, next = expl
        b = explode_addnext(x.b, next)
        return SnailFishNumber(a, b), (prev, nothing)
    end
    b, expl = explode_snailfish(x.b, level+1)
    if expl != nothing
        prev, next = expl
        a = explode_addprev(x.a, prev)
        return SnailFishNumber(a, b), (nothing, next)
    end
    # No explosion happened; don't allocate then:
    return x, nothing
end

@test first(explode_snailfish([[[[[9,8],1],2],3],4])) == snailfish([[[[0,9],2],3],4])
@test first(explode_snailfish([7,[6,[5,[4,[3,2]]]]])) == snailfish([7,[6,[5,[7,0]]]])
@test first(explode_snailfish([[6,[5,[4,[3,2]]]],1])) == snailfish([[6,[5,[7,0]]],3])
@test first(explode_snailfish([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]])) == snailfish([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]])
@test first(explode_snailfish([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]])) == snailfish([[3,[2,[8,0]]],[9,[5,[7,0]]]])

function split_snailfish(x::Int)
    x < 10 && return x, false
    a = x ÷ 2
    b = x - a
    return SnailFishNumber(a, b), true
end

function split_snailfish(x::SnailFishNumber)
    a, spl = split_snailfish(x.a)
    spl && return SnailFishNumber(a, x.b), true
    b, spl = split_snailfish(x.b)
    spl && return SnailFishNumber(x.a, b), true
    # No split occurred; don't allocate then:
    return x, false
end

function reduce_snailfish(x::SnailFishNumber)
    while true
        x, expl = explode_snailfish(x)
        expl == nothing || continue
        x, spl = split_snailfish(x)
        spl && continue
        return x
    end
end

function Base.:(+)(a::SnailFishNumber, b)
    x = SnailFishNumber(a, b)
    y = reduce_snailfish(x)
    return y
end

x = snailfish([[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]])
y = snailfish([[[[0,7],4],[[7,8],[6,0]]],[8,1]])
@test reduce_snailfish(x) == y
@test x.a + x.b == y

magnitude(x::Int) = x
magnitude(x::SnailFishNumber) = 3magnitude(x.a) + 2magnitude(x.b)

test = read_snailfish_numbers("test.txt")
stest = snailfish([[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]])
@test sum(test) == stest
@test magnitude(stest) == 4140

input = read_snailfish_numbers("input.txt")
@show magnitude(sum(input))
