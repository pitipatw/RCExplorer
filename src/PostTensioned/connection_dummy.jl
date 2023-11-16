using CSV, DataFrames, JSON
using Dates
using Makie, GLMakie
include("Pt_Catalog.jl")

"""
catalog format
fc', as, ec, fpe, Pu, Mu, Vu, embodied
"""
function matchitnow()
catalog = CSV.read(joinpath(@__DIR__,"Outputs\\output_static.csv"), DataFrame);
sort!(catalog, [:carbon, :ec])
#test input
open(joinpath(@__DIR__,"JSON\\test_input.json"), "r") do f
    global demands = DataFrame(JSON.parse(f, dicttype=Dict{String,Any}))
    ns = size(demands)[1]
    demands[!, :idx] = 1:ns
end

demands[!,"e_idx"] .+= 1
demands[!, "s_idx"] .+=1
e_idx = 1 
for i in 1:size(demands)[1]
    if i !=1
        demands[i-1, :e_idx] = e_idx
        if demands[i,:s_idx] < demands[i-1,:s_idx]
            e_idx +=1 
        end
        
    end
    if i == size(demands)[1]
        demands[i, :e_idx] = e_idx
    end
end
demands
# function match_demands(demands, catalog)
# sections_per_element = Dict( k => 0 for k in unique(demands[!, "e_idx"]))
elements_to_sections = Dict(k => Int[] for k in unique(demands[!, "e_idx"]))
#goes in a loop
ns = size(demands)[1]
ne = unique(demands[!,:e_idx]) #python starts at 0

#number of available choices
nc = size(catalog, 1)
output_results = Dict{Int64,Vector{Int64}}()

#go through each section.
for i = 1:ns
    en = demands[i, "e_idx"]
    sn = demands[i, "s_idx"]
    push!(elements_to_sections[en], i)

    pu = demands[i,"pu"]
    mu = demands[i,"mu"]
    vu = demands[i,"vu"]
    ec_max = demands[i,"ec_max"]

    global feasible_sections = filter([:Pu,:Mu,:Vu,:ec] => (x1,x2,x3,x4) -> 
    x1>pu &&
    x2>mu &&
    #x3>vu &&
    x4<= ec_max, 
    catalog
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

# output_results = match_demands(demands,catalog)

"""
Find the optimum result for each element. 
For the same element, will use the same fc′ steel size and post tensioning stress.

"""
#function find_optimum(output_results, elements_to_sections, demands)
ns = size(demands)[1]
ne = unique(demands[!,:e_idx]) #python starts at 0
element_designs = Dict(k=> DataFrame() for k in unique(demands[!,"e_idx"]))
for i in ne #loop each element
    # i = 1
    #try to see what variables we have.

avai_fc′ = unique(catalog[!, :fc′])
avai_as = unique(catalog[!, :as])
avai_fpe = unique(catalog[!, :fpe])

sections = elements_to_sections[i]
#sections index that are with that element.
# sections = filter(:e_idx => x-> x==i, demands)

    for s in sections
    # s = 1
        feasible_idx = output_results[s]
        sub_catalog = catalog[feasible_idx, :]
        all_fc′ =  unique(sub_catalog[!, :fc′])
        all_as = unique(sub_catalog[!, :as])
        all_fpe = unique(sub_catalog[!, :fpe])

        filter!(e->e ∈ all_fc′, avai_fc′)
        filter!(e->e ∈ all_as, avai_as)
        filter!(e->e ∈ all_fpe, avai_fpe)
        println("#####")
        println(length(avai_fc′))
        println(length(avai_as))
        println(length(avai_fpe))
        #now we filter the design space by avai...
        #end
    end

    for s in sections
        feasible_idx = output_results[s]
        sub_catalog = catalog[feasible_idx, :]
        element_designs[s] = filter(:fc′ => x -> x ∈ avai_fc′, sub_catalog)
        element_designs[s] = filter(:as  => x -> x ∈ avai_as , element_designs[s])
        element_designs[s] = filter(:fpe => x -> x ∈ avai_fpe, element_designs[s])
    end

end
element_designs

final_designs = Vector{Vector}(undef, length(element_designs))
for i in 1:length(element_designs) 
    # available_designs = sort(element_designs[i],[:]
    final_designs[i] = Array{Float64,1}(element_designs[i][1,:])
end

element_designs[s] = filter(:fc′ => x -> x ∈ avai_fc′, sub_catalog)
element_designs[s] = filter(:as => x -> x ∈ avai_as, element_designs[s])
element_designs[s] = filter(:fpe => x -> x ∈ avai_fpe, element_designs[s])


begin
L = 200
f1 = Figure(resolution = (1800,5000))
Axes = Vector{Axis}(undef, length(ne))
n = 3
m = 4
start = 1
for i in eachindex(ne)
    e = ne[i]
    #find how many elements in that section.
    sections = elements_to_sections[e]
    @show ns = length(sections)
    ix = div(i-1,n)+1
    iy = mod(i-1,n)
    # @show (ix,iy)
    Axes[e] = Axis(f1[ix,iy], aspect = DataAspect(), title = "$e", xticks = 0:100:(ns*50),
    #limits = (0,(ns+1)*50,-L,10)
    )
    lines!(Axes[e], 50 .* (1:ns), -L.*(getindex.(final_designs[start:start+ns-1],3)))
    text!( (10,-125), text = join(getindex.(final_designs[start:start+ns-1],1), " - "))

    text!((10,-150), text = join(getindex.(final_designs[start:start+ns-1],2)," - ") )
    text!((10,-175), text = join(getindex.(final_designs[start:start+ns-1],4)," - "))
    start += ns
end
end
return f1
end


 matchitnow()
# save("section_design_trial_27102023.png", f1)






# outvod = Vector{Vector{Dict}}(undef, size(outr,1))
# for i = axes(outr,1)
#     temp = Vector{Dict}(undef, size(outr[i],1))
#     for j = axes(outr[i],1)
#         temp[j] = Dict( "fc" => outr[i][j,1],
#                         "as" => outr[i][j,2],
#                         "ec" => outr[i][j,3],
#                         "fpe"=> outr[i][j,4],
#                         "pu" => outr[i][j,5],
#                         "mu" => outr[i][j,6],
#                         "vu" => outr[i][j,7],
#                         "embodied"=> outr[i][j,8],
#                         "element" => data[i]["e_idx"],
#                         )
#     end
#     outvod[i] = temp
# end

#add the last spot, for optimum choice for the section
#What is optimum? 

# Post process
# postprocess(outvod, data)

# Minimum embodied carbon.
# Same ec as the previous one
# Same fc' as the previous one.


# 
    # catch 
    #     println("Error")
    #     println("Closing the server")
    #     WebSockets.close(server)
    #     return server
    # end
