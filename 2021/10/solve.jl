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
    return incomplete, nothing
end

const SCORE = Dict(
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137,
)

function score_corrupted(file)
    s = 0
    for l in eachline(file)
        status, c = parseline(l)
        status == corrupt || continue
        s += SCORE[c]
    end
    s
end

@test score_corrupted("test.txt") == 26397
@show score_corrupted("input.txt")
