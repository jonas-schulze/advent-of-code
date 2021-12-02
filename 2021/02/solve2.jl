using Test

function navigate(input)
    aim = hpos = depth = 0
    for line in eachline(input)
        dir, n_ = split(line)
        n = parse(Int, n_)
        if dir == "forward"
            hpos += n
            depth += aim*n
        elseif dir == "up"
            aim -= n
        elseif dir == "down"
            aim += n
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

@test navigate(IOBuffer(sample)) == (15, 60, 900)

@show navigate("input.txt")
