using Test

nincreased(v) = count(diff(v) .> 0)

sample = [
199
200
208
210
200
207
240
269
260
263
]

@test nincreased(sample) == 7

data = map(readlines("input.txt")) do l
    parse(Int, l)
end

@show nincreased(data)
