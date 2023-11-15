using CSV, DataFrames, JSON
using Dates


"""
catalog format
fc', as, ec, fpe, Pu, Mu, Vu, embodied
"""
catalog = CSV.read(joinpath(@__DIR__, "Outputs\\output_static.csv"), DataFrame)

#test input
open(joinpath(@__DIR__, "JSON\\small_test_input.json"), "r") do f
    global demands = DataFrame(JSON.parse(f, dicttype=Dict{String,Any}))
    ns = size(demands)[1]
    demands[!, :idx] = 1:ns
end

# function match_demands(demands, catalog)
# sections_per_element = Dict( k => 0 for k in unique(demands[!, "e_idx"]))
elements_to_sections = Dict(k => Int[] for k in unique(demands[!, "e_idx"]))
#goes in a loop
ns = size(demands)[1]
ne = maximum(demands[!, :e_idx]) + 1 #python starts at 0

#number of available choices
nc = size(catalog, 1)
output_results = Dict{Int64,Vector{Int64}}()

#go through each section.
for i = 1:ns
    en = demands[i, "e_idx"]
    sn = demands[i, "s_idx"]
    push!(elements_to_sections[en], i)

    pu = demands[i, "pu"]
    mu = demands[i, "mu"] / 10
    vu = demands[i, "vu"]
    ec_max = demands[i, "ec_max"]

    global feasible_sections = filter([:Pu, :Mu, :Vu, :ec] => (x1, x2, x3, x4) ->
            x1 > pu &&
                x2 > mu #&&
        #x3>vu &&
        #x4<= ec_max, 
        , catalog
    )

    if size(feasible_sections)[1] == 0
        println("No results found for section $i: element $en")
        output_results[i] = []
        # println(outr)
    else
        output_results[i] = feasible_sections[!, :ID]
        # println(outr)
    end
end

# return output_results
# end

output_results = match_demands(demands, catalog)

"""
Find the optimum result for each element. 
For the same element, will use the same fc′ steel size and post tensioning stress.

"""
#function find_optimum(output_results, elements_to_sections, demands)
ns = size(demands)[1]
ne = maximum(demands[!, :e_idx]) + 1 #python starts at 0
element_designs = Dict(k => DataFrame() for k in unique(demands[!, "e_idx"]))
# for i in 1:ne
i = 1
#try to see what variables we have.

avai_fc′ = unique(catalog[!, :fc′])
avai_as = unique(catalog[!, :as])
avai_fpe = unique(catalog[!, :fpe])

sections = elements_to_sections[i]
#sections index that are with that element.
# sections = filter(:e_idx => x-> x==i, demands)

# for s in sections
s = 1
feasible_idx = output_results[s]
sub_catalog = catalog[feasible_idx, :]
all_fc′ = unique(sub_catalog[!, :fc′])
all_as = unique(sub_catalog[!, :as])
all_fpe = unique(sub_catalog[!, :fpe])

filter!(e -> e ∈ all_fc′, avai_fc′)
filter!(e -> e ∈ all_as, avai_as)
filter!(e -> e ∈ all_fpe, avai_fpe)

#now we filter the design space by avai...


#end

element_designs[s] = filter(:fc′ => x -> x ∈ avai_fc′, sub_catalog)
element_designs[s] = filter(:as => x -> x ∈ avai_as, element_designs[s])
element_designs[s] = filter(:fpe => x -> x ∈ avai_fpe, element_designs[s])










outvod = Vector{Vector{Dict}}(undef, size(outr, 1))
for i = axes(outr, 1)
    temp = Vector{Dict}(undef, size(outr[i], 1))
    for j = axes(outr[i], 1)
        temp[j] = Dict("fc" => outr[i][j, 1],
            "as" => outr[i][j, 2],
            "ec" => outr[i][j, 3],
            "fpe" => outr[i][j, 4],
            "pu" => outr[i][j, 5],
            "mu" => outr[i][j, 6],
            "vu" => outr[i][j, 7],
            "embodied" => outr[i][j, 8],
            "element" => data[i]["e_idx"],
        )
    end
    outvod[i] = temp
end

#add the last spot, for optimum choice for the section
#What is optimum? 

# Post process
# postprocess(outvod, data)

# Minimum embodied carbon.
# Same ec as the previous one
# Same fc' as the previous one.

global outvod
jsonfile = JSON.json(outvod)
HTTP.send(ws, jsonfile)
open(joinpath(@__DIR__, "output_" * filename), "w") do f
    write(f, jsonfile)
    println("output_" * filename * " written succesfully")

end


for i in eachindex(outvod)
    println(size(outvod[i]))
end

# catch 
#     println("Error")
#     println("Closing the server")
#     WebSockets.close(server)
#     return server
# end
