using Test

function navigate(input)
    hpos = depth = 0
    for line in eachline(input)
        dir, n_ = split(line)
        n = parse(Int, n_)
        if dir == "forward"
            hpos += n
        elseif dir == "up"
            depth -= n
        elseif dir == "down"
            depth += n
        else
            error("malformed line: $line")
        end
    end
    return hpos, depth, hpos*depth
end

sample = """
forward 5
down 5
forward 8
up 3
down 8
forward 2
"""

@test navigate(IOBuffer(sample)) == (15, 10, 150)

@show navigate("input.txt")
