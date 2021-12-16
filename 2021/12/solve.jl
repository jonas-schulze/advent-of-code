using Test

function read_graph(file)
    adj = Dict{String,Vector{String}}()
    r = r"(\w+)-(\w+)"
    for l in eachline(file)
        v, w = match(r, l).captures
        adj_v = get!(adj, v, String[])
        adj_w = get!(adj, w, String[])
        push!(adj_v, w)
        push!(adj_w, v)
    end
    return adj
end

issmall(cave::String) = islowercase(first(cave))

explore(f, adj, anytwice) = explore(f, adj, anytwice, ["start"])

function explore(f, adj, anytwice, path)
    v = last(path)
    v == "end" && return f(path)
    for w in adj[v]
        w == "start" && continue
        if issmall(w)
            once = w in path
            once && anytwice && continue
            explore(f, adj, anytwice|once, vcat(path, w))
        else
            explore(f, adj, anytwice, vcat(path, w))
        end
    end
end

function count_paths(adj, allow2=false)
    n = 0
    explore(adj, !allow2) do _
        n += 1
    end
    return n
end

function show_paths(adj, allow2=false)
    explore(adj, !allow2) do path
        println(path)
    end
end

adj1 = read_graph("test1.txt")
adj2 = read_graph("test2.txt")
adj3 = read_graph("test3.txt")

@test count_paths(adj1) == 10
@test count_paths(adj2) == 19
@test count_paths(adj3) == 226
@test count_paths(adj1, true) == 36
@test count_paths(adj2, true) == 103
@test count_paths(adj3, true) == 3509

adj = read_graph("input.txt")

@show count_paths(adj)
@show count_paths(adj, true)
