using Test

const VENT = r"(\d+),(\d+) -> (\d+),(\d+)"

function parse_vent(s::String)
    m = match(VENT, s)
    m == nothing && @show s
    map(m.captures) do x
        parse(Int, x)
    end
end

function noverlaps(file, diagonal=false)
    vents = map(parse_vent, readlines(file))
    X = Y = 0
    for v in vents
        x1, y1, x2, y2 = v
        X = max(X, x1, x2)
        Y = max(Y, y1, y2)
    end
    # account for 0:
    X += 1
    Y += 1
    lines = zeros(Int, X, Y)
    for v in vents
        x1, y1, x2, y2 = v
        if x1 == x2
            x = x1 + 1
            y1, y2 = minmax(y1, y2)
            for y in y1+1:y2+1
                lines[x, y] += 1
            end
        elseif y1 == y2
            y = y1 + 1
            x1, x2 = minmax(x1, x2)
            for x in x1+1:x2+1
                lines[x, y] += 1
            end
        elseif diagonal
            dx = sign(x2 - x1)
            dy = sign(y2 - y1)
            @assert abs(x2 - x1) == abs(y2 - y1)
            x = x1 + 1
            y = y1 + 1
            for _ in 0:abs(x2 - x1)
                lines[x, y] += 1
                x += dx
                y += dy
            end
        end
    end
    count(>=(2), lines)
end

@test noverlaps("test.txt") == 5
@show noverlaps("input.txt")

@test noverlaps("test.txt", true) == 12
@show noverlaps("input.txt", true)
