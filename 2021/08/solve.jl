using Test

function parseline(l)
    s1, s2 = split(l, '|')
    pattern = split(s1)
    output = split(s2)
    return pattern, output
end

# 0: 6 segments
# 1: 2 segments
# 2: 5 segments
# 3: 5 segments
# 4: 4 segments
# 5: 5 segments
# 6: 6 segments
# 7: 3 segments
# 8: 7 segments
# 9: 6 segments

function count1478(file)
    c = 0
    for l in readlines(file)
        _, output = parseline(l)
        for d in output
            length(d) in (2, 3, 4, 7) || continue
            c += 1
        end
    end
    return c
end

@test count1478("test.txt") == 26
@show count1478("input.txt")
