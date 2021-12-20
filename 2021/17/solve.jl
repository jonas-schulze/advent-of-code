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

function max_probe_height(tx, ty)
    # Minimum launch velocity to reach target area in x direction:
    vx_min = floor(Int, sqrt(0.25 + 2minimum(tx)) - 0.5)

    # Velocity to overshoot target area in x direction within `n` steps,
    # i.e. `vx + (vx-1) + ... + (vx-(n-1)) > maximum(tx)`:
    vx_max(n) = ceil(Int, maximum(tx)/(n-1) + n/2)

    # Due to how gravity is modelled, the probe will always reach `y=0` with a
    # velocity of `vy=-abs(vy)-1`. Therefore, if `vy > abs(minimum(ty))-1` the
    # probe will always overshoot the target area within 1 step.
    #
    # Assume that it's always possible to hit the target area in y direction.
    vy = abs(minimum(ty))
    local ny
    while true
        vy -= 1
        ny = touches_target_y(vy, ty)
        isempty(ny) && continue

        # Now, find a horizontal launch velocity such that the probe hits the
        # target area at the same time in both directions x and y.
        for vx in vx_min:vx_max(last(ny))
            nx = touches_target_x(vx, tx)
            isempty(nx ∩ ny) && continue

            # Compute probe height:
            return vy*(vy+1)÷2
        end
    end
end

@test max_probe_height(20:30, -10:-5) == 45
@show max_probe_height(209:238, -86:-59)
