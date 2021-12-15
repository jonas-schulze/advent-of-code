using Test

# grid will be transposed, but that doesn't matter
function read_grid(file)
    grid = Matrix{Int8}(undef, 10, 10)
    i = 0
    for l in eachline(file)
        for c in l
            i += 1
            grid[i] = Int8(c) - Int8('0')
        end
    end
    grid
end

function simulate!(grid, nsteps)
    n = 0
    will_flash = falses(size(grid))
    did_flash = falses(size(grid))
    for _ in 1:nsteps
        # Increase energy levels:
        for i in eachindex(grid)
            grid[i] += 1
            will_flash[i] = grid[i] > 9
        end
        # Trigger flashes:
        fill!(did_flash, false)
        while true
            any_flashed = false
            for I in CartesianIndices(will_flash)
                will_flash[I] || continue
                did_flash[I] && continue
                did_flash[I] = true
                any_flashed = true
                for Δ in CartesianIndices((-1:1, -1:1))
                    J = I + Δ
                    checkbounds(Bool, grid, J) || continue
                    grid[J] += 1
                    will_flash[J] = grid[J] > 9
                end
            end
            any_flashed || break
        end
        @assert will_flash == did_flash
        # Count flashes:
        n += count(did_flash)
        # Reset energy levels:
        @assert (grid .> 9) == did_flash
        for i in eachindex(grid)
            grid[i] > 9 || continue
            grid[i] = 0
        end
    end
    return n
end

test = read_grid("test.txt")
@test simulate!(test, 10) == 204
@test simulate!(test, 90) == 1656 - 204

input = read_grid("input.txt")
@show simulate!(input, 100)
