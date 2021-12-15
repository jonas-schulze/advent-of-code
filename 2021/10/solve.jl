using Test

const OPEN  = ['(', '[', '{', '<']
const CLOSE = [')', ']', '}', '>']

@assert extrema(CLOSE - OPEN) == (1, 2)

delims_match(open::Char, close::Char) = 0 <= close - open <= 2

@enum Status begin
    ok
    incomplete
    corrupt
end

function parseline(line)
    stack = Char[]
    for c in line
        if c in OPEN
            push!(stack, c)
            continue
        end
        isempty(stack) && return corrupt, c
        o = pop!(stack)
        delims_match(o, c) || return corrupt, c
    end
    isempty(stack) && return ok, nothing
    return incomplete, stack
end

function score_corrupted(file)
    s = 0
    SCORE = Dict(
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
    )
    for l in eachline(file)
        status, c = parseline(l)
        status == corrupt || continue
        s += SCORE[c]
    end
    s
end

function score_incomplete(file)
    s = Int[]
    SCORE = Dict(
        '(' => 1,
        '[' => 2,
        '{' => 3,
        '<' => 4,
    )
    for l in eachline(file)
        status, stack = parseline(l)
        status == incomplete || continue
        _s = 0
        reverse!(stack)
        for o in stack
            _s *= 5
            _s += SCORE[o]
        end
        push!(s, _s)
    end
    sort!(s)
    n = length(s)
    m = 1 + n÷2
    s[m]
end

@test score_corrupted("test.txt") == 26397
@show score_corrupted("input.txt")

@test score_incomplete("test.txt") == 288957
@show score_incomplete("input.txt")
