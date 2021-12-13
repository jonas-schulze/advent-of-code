using Test

function parseline(l)
    s1, s2 = split(l, '|')
    pattern = split(s1)
    output = split(s2)
    return pattern, output
end

# Conversion from segment character to index:
s2i(s) = s - 'a' + 1
i2s(i) = i + 'a' - 1

function segments(ps)
    counts = zeros(Int, 7)
    # Variables are named after the segments they represent.
    local cf # 1
    for pattern in ps
        l = length(pattern)
        # Skip digits 4 and 8, memorize digit 1:
        if l == 4 || l == 7
            continue
        elseif l == 2
            cf = pattern
        end
        # Count occurrences of individual segments:
        for segment in pattern
            i = s2i(segment)
            counts[i] += 1
        end
    end
    # Deduce segments:
    σ = sortperm(counts)
    @assert counts[σ] == [3, 4, 5, 6, 6, 7, 7]
    e = i2s(σ[1])
    b = i2s(σ[2])
    d = i2s(σ[3])
    cg = join(i2s(σ[i]) for i in 4:5)
    af = join(i2s(σ[i]) for i in 6:7)
    a = only(setdiff(af, cf))
    g = only(setdiff(cg, cf))
    c = cg[1] == g ? cg[2] : cg[1]
    f = af[1] == a ? af[2] : af[1]
    return [a, b, c, d, e, f, g]
end

const DIGITS = Dict(
    "abcefg" => 0,
    "cf" => 1,
    "acdeg" => 2,
    "acdfg" => 3,
    "bcdf" => 4,
    "abdfg" => 5,
    "abdefg" => 6,
    "acf" => 7,
    "abcdefg" => 8,
    "abcdfg" => 9,
)

function number(output, segments)
    # Canonicalize segment names and order,
    # then translate them to the digit they represent:
    σ = sortperm(segments)
    digits = map(output) do pattern
        cpattern = [i2s(σ[s2i(s)]) for s in pattern]
        sort!(cpattern)
        DIGITS[join(cpattern)]
    end
    # Change endianness of digits and convert from decimal:
    reverse!(digits)
    return evalpoly(10, digits)
end

function sum_output(file)
    s = 0
    for l in readlines(file)
        ps, output = parseline(l)
        seg = segments(ps)
        num = number(output, seg)
        s += num
    end
    return s
end

@test sum_output("test.txt") == 61229
@show sum_output("input.txt")
