using Test

function read_polymers(file)
    local template
    rules = Dict{Tuple{Char,Char},Char}()
    open(file) do io
        template = readline(io)
        blank = readline(io)
        @assert isempty(blank)
        for l in eachline(io)
            A = l[1]
            B = l[2]
            C = l[end]
            rules[(A, B)] = C
        end
    end
    return template, rules
end

polymerize(polymer::String, args...) = join(polymerize(collect(polymer), args...))

function polymerize(polymer::Vector{Char}, rules)
    next = Char[]
    n = length(polymer)
    A = first(polymer)
    for i in 2:n
        push!(next, A)
        B = polymer[i]
        C = get(rules, (A, B), nothing)
        C == nothing || push!(next, C)
        A = B
    end
    push!(next, last(polymer))
    return next
end

function polymerize(polymer::Vector{Char}, rules, nsteps)
    for _ in 1:nsteps
        polymer = polymerize(polymer, rules)
    end
    return polymer
end

function Δcount(template, rules, nsteps)
    polymer = polymerize(collect(template), rules, nsteps)
    counts = Dict{Char,Int}()
    for el in polymer
        c = get(counts, el, 0)
        counts[el] = c+1
    end
    min, max = extrema(values(counts))
    return max - min
end

template, rules = read_polymers("test.txt")
@test polymerize(template, rules) == "NCNBCHB"
@test polymerize(template, rules, 2) == "NBCCNBBBCBHCB"
@test polymerize(template, rules, 3) == "NBBBCNCCNBBNBNBBCHBHHBCHB"
@test polymerize(template, rules, 4) == "NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB"
@test Δcount(template, rules, 10) == 1588

template, rules = read_polymers("input.txt")
@show Δcount(template, rules, 10)
