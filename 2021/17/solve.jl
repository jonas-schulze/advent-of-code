using Test

function touches_target_x(vx, tx)
    nfirst = typemax(vx)
    nlast = typemin(vx)
    n = 0
    x = zero(vx)
    while true
        n += 1
        x += vx
        vx -= 1
        if x in tx
            nfirst = min(nfirst, n)
            nlast = max(nlast, n)
        end
        x > maximum(tx) && break
        if vx == 0
            nlast = typemax(vx)
            break
        end
    end
    return nfirst:nlast
end

function touches_target_y(vy, ty)
    nfirst = typemax(vy)
    nlast = typemin(vy)
    # If the probe is launched upwards, it will reach `y=0` again with a
    # velocity directed downwards. Skip this upward simulation:
    if vy > 0
        n = 2vy + 1
        vy = -vy - 1
    else
        n = 0
    end
    y = zero(vy)
    while true
        n += 1
        y += vy
        vy -= 1
        if y in ty
            nfirst = min(nfirst, n)
            nlast = max(nlast, n)
        end
        y < minimum(ty) && break
    end
    return nfirst:nlast
end

∞ = typemax(Int)
@test touches_target_x(7, 20:30) == 4:∞
@test touches_target_x(6, 20:30) == 5:∞
@test touches_target_x(9, 20:30) == 3:4
@test isempty(touches_target_x(17, 20:30))

@test touches_target_y(2, -10:-5) == 7:7
@test touches_target_y(3, -10:-5) == 9:9
@test touches_target_y(0, -10:-5) == 4:5
@test isempty(touches_target_y(10, -10:-5))
@test isempty(touches_target_y(11, -10:-5))
@test isempty(touches_target_y(-11, -10:-5))

# Minimum launch velocity `vx` to reach target area after `n` steps:
function vx_min(tx, n)
    # If the probe doesn't come to a halt, the velocities must fulfill
    # `vx + (vx-1) + ... + (vx-(n-1)) >= minimum(tx)`. Thus:
    v = minimum(tx)/n + (n-1)/2
    # If, however, the probe has become stationary in the meantime, describe
    # the minimum velocity to become stationary within the target area, instead:
    if v <= n
        v = -0.5 + sqrt(0.25 + 2minimum(tx))
    end
    return floor(Int, v)
end

# Maximum launch velocity `vx` to be within target area after `n` steps,
# i.e. `vx + (vx-1) + ... + (vx-(n-1)) <= maximum(tx)`:
vx_max(tx, n) = ceil(Int, maximum(tx)/n + (n-1)/2)

function initial_velocities(f, tx, ty)
    # Due to how gravity is modelled, the probe will always reach `y=0` with a
    # velocity of `vy=-abs(vy)-1`. Therefore, if `vy > abs(minimum(ty))-1` the
    # probe will always overshoot the target area within 1 step.
    #
    # Iterate all velocities with decreasing `vy` and maximum height:
    vy = abs(minimum(ty))
    vy_min = -vy
    while vy >= vy_min
        vy -= 1
        ny = touches_target_y(vy, ty)
        isempty(ny) && continue

        # Now, find a horizontal launch velocity such that the probe hits the
        # target area at the same time in both directions x and y.
        vmin = vx_min(tx, last(ny))
        vmax = vx_max(tx, first(ny))
        for vx in vmin:vmax
            nx = touches_target_x(vx, tx)
            isempty(nx ∩ ny) && continue

            # Report initial velocity:
            f(vx, vy) && return
        end
    end
end

function max_probe_height(tx, ty)
    local height
    initial_velocities(tx, ty) do vx, vy
        height = vy*(vy+1)÷2
        return true
    end
    return height
end

@test max_probe_height(20:30, -10:-5) == 45
@show max_probe_height(209:238, -86:-59)

function num_initial_velocities(tx, ty)
    n = 0
    initial_velocities(tx, ty) do vx, vy
        n += 1
        return false
    end
    return n
end

@test num_initial_velocities(20:30, -10:-5) == 112
@show num_initial_velocities(209:238, -86:-59)
