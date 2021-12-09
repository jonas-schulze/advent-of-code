using Test
using OffsetArrays

function read_population(file)
    pop = OffsetArray(zeros(Int, 1+8), 0:8)
    open(file) do io
        while !eof(io)
            age = read(io, Char) - '0'
            pop[age] += 1
            sep = read(io, Char)
            sep == '\n' && break
            @assert sep == ','
        end
    end
    return pop
end

function simulate!(pop, n=1)
    old = pop
    new = copy(pop)
    for _ in 1:n
        old, new = new, old
        nparents = old[0]
        circshift!(new, old, -1)
        new[6] += nparents
    end
    copyto!(pop, new)
    return pop
end

tpop = read_population("test.txt")
@test sum(tpop) == 5
@test sum(simulate!(tpop, 18)) == 26
@test sum(simulate!(tpop, 80-18)) == 5934
@test sum(simulate!(tpop, 256-80)) == 26984457539

pop = read_population("input.txt")
@show sum(simulate!(pop, 80))
@show sum(simulate!(pop, 256-80))
