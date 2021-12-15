using Plots

include("solve.jl")

function animate_grid(file; nsteps, fps=5, annotate=false)
    grid = read_grid(file)

    # Create color palette:
    z = @. 1.0 - log10(10:-1:1)
    colors = collect(cgrad([:black, :white], z))
    colors = circshift(colors, 1)

    # Some helpers:
    title(i) = string("Iteration ", lpad(i, padding, '0'))
    annotations(grid) = vec([(I[1], I[2], string(grid[I])) for I in CartesianIndices(grid)])

    # Plot initial energies:
    anim = Animation()
    kwargs = (
        aspect_ratio=1,
        lims=(0.5,10.5),
        #framestyle=:none,
        clims=((0, 9)),
        color=colors,
        colorbar=false,
        size=(400, 400),
    )
    padding = ndigits(nsteps)
    p = heatmap(grid; title=title(0), kwargs...)
    annotate && annotate!(annotations(grid))
    frame(anim, p)

    # Simulate and plot energies:
    for i in 1:nsteps
        simulate!(grid, 1)
        p = heatmap(grid; title=title(i), kwargs...)
        annotate && annotate!(annotations(grid))
        frame(anim, p)
    end

    # Save animation:
    f, ext = splitext(file)
    gif(anim, f*".gif", fps=fps)
end

animate_grid("test.txt", nsteps=250)
animate_grid("input.txt", nsteps=400)
