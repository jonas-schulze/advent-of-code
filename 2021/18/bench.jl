using BenchmarkTools

module V1 include("solve_tree.jl") end
module V2 include("solve_traversal.jl") end

minratio(b1, b2) = ratio(minimum(b1), minimum(b2))

b1_tree = @benchmark V1.magnitude(sum($(V1.input)))
b1_trav = @benchmark V2.magnitude(sum($(V2.input)))

@info "1st puzzle:" minratio(b1_tree, b1_trav)

b2_tree = @benchmark maximum(V1.magnitude(x + y) for x in $(V1.input), y in $(V1.input))
b2_trav = @benchmark maximum(V2.magnitude(x + y) for x in $(V2.input), y in $(V2.input))

@info "2nd puzzle:" minratio(b2_tree, b2_trav)
