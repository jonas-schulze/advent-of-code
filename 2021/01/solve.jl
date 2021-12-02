using Test

nincreased(v) = count(diff(v) .> 0)
nincreased(v, n) = nincreased(map(sum, zip((v[i:end] for i in 1:n)...)))

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
@test nincreased(sample, 3) == 5

data = map(readlines("input.txt")) do l
    parse(Int, l)
end

@show nincreased(data)
@show nincreased(data, 3)
