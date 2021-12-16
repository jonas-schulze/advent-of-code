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

explore(adj) = explore(adj, ["start"])

function explore(adj, path)::Vector{Vector{String}}
    v = last(path)
    v == "end" && return [path]
    paths = Vector{String}[]
    for w in adj[v]
        issmall(w) && w in path && continue
        next = explore(adj, vcat(path, w))
        append!(paths, next)
    end
    return paths
end

adj1 = read_graph("test1.txt")
adj2 = read_graph("test2.txt")
adj3 = read_graph("test3.txt")

@test length(explore(adj1)) == 10
@test length(explore(adj2)) == 19
@test length(explore(adj3)) == 226

adj = read_graph("input.txt")

@show length(explore(adj))
