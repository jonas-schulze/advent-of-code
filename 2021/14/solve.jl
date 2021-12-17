using Test

function parse_polymer(s::String)
    p = Dict{Tuple{Char,Char},Int}()
    # Add start and end markers:
    c = vcat('_', collect(s), '_')
    A = first(c)
    for i in 2:length(c)
        B = c[i]
        n = get(p, (A, B), 0)
        p[(A, B)] = n + 1
        A = B
    end
    return p
end

function read_polymers(file)
    local template
    rules = Dict{Tuple{Char,Char},Char}()
    open(file) do io
        # Read template:
        l = readline(io)
        template = parse_polymer(l)
        # Read polymerization rules:
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

function polymerize(polymer, rules)
    next = empty(polymer)
    for ((A, B), n) in polymer
        C = get(rules, (A, B), nothing)
        if C == nothing
            next[(A, B)] = n
        else
            n1 = get(next, (A, C), 0)
            next[(A, C)] = n + n1
            n2 = get(next, (C, B), 0)
            next[(C, B)] = n + n2
        end
    end
    return next
end

function polymerize(polymer, rules, nsteps)
    for _ in 1:nsteps
        polymer = polymerize(polymer, rules)
    end
    return polymer
end

function count_polymer(polymer)
    counts = Dict{Char,Int}()
    # Counting occurrences inside pairs will consider every interior element
    # twice. This is why the start and end markers are needed.
    for ((A, B), n) in polymer
        a = get(counts, A, 0)
        counts[A] = a + n
        b = get(counts, B, 0)
        counts[B] = b + n
    end
    map!(x -> x÷2, values(counts))
    # Remove start and end marker:
    delete!(counts, '_')
    return counts
end

function Δcount(polymer)
    counts = count_polymer(polymer)
    min, max = extrema(values(counts))
    return max - min
end

template, rules = read_polymers("test.txt")
@test polymerize(template, rules) == parse_polymer("NCNBCHB")
@test polymerize(template, rules, 2) == parse_polymer("NBCCNBBBCBHCB")
@test polymerize(template, rules, 3) == parse_polymer("NBBBCNCCNBBNBNBBCHBHHBCHB")
@test polymerize(template, rules, 4) == parse_polymer("NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB")

p10 = polymerize(template, rules, 10)
p40 = polymerize(p10, rules, 30)
@test Δcount(p10) == 1588
@test Δcount(p40) == 2188189693529

template, rules = read_polymers("input.txt")
p10 = polymerize(template, rules, 10)
p40 = polymerize(p10, rules, 30)
@show Δcount(p10)
@show Δcount(p40)
