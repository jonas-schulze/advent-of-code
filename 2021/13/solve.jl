using Test
using OffsetArrays

function read_manual(file)
    dots = Tuple{Int,Int}[]
    folds = Tuple{Char,Int}[]
    open(file) do io
        # read dots:
        dot = r"(\d+),(\d+)"
        for l in eachline(io)
            isempty(l) && break
            as, bs = match(dot, l).captures
            a = parse(Int, as)
            b = parse(Int, bs)
            push!(dots, (a, b))
        end
        # read fold instructions:
        fold = r"fold along (.)=(\d+)"
        for l in eachline(io)
            xys, fs = match(fold, l).captures
            xy = first(xys)
            f = parse(Int, fs)
            push!(folds, (xy, f))
        end
    end
    return dots, folds
end

fold1(f, x) = x > f ? (2f - x) : x # spaces around `-` are needed :-(
fold(::Val{'x'}, f, x, y) = fold1(f, x), y
fold(::Val{'y'}, f, x, y) = x, fold1(f, y)

function fold_paper!(dots, (xy, f))
    d = Val(xy)
    map!(dots, dots) do (x, y)
        fold(d, f, x, y)
    end
end

function count_after_fold(file)
    dots, folds = read_manual(file)
    fold_paper!(dots, folds[1])
    length(Set(dots))
end

function fold_manual(file)
    dots, folds = read_manual(file)
    # Perform all fold instructions:
    dots = foldl(fold_paper!, folds, init=dots)
    # Collect dots on coordinate system:
    maxcol = maximum(first, dots)
    maxrow = maximum(last, dots)
    sheet = OffsetArray(fill(' ', maxrow+1, maxcol+1), 0:maxrow, 0:maxcol)
    for (x, y) in dots
        sheet[y, x] = '#'
    end
    # Draw as string:
    io = IOBuffer()
    for c in eachslice(sheet, dims=1)
        join(io, c)
        println(io)
    end
    String(take!(io))
end

@test count_after_fold("test.txt") == 17
@show count_after_fold("input.txt")

@test fold_manual("test.txt") == """
#####
#   #
#   #
#   #
#####
"""

println(fold_manual("input.txt"))
