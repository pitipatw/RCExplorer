using CSV, DataFrames, JSON
using Dates

"""
catalog format
fc', as, ec, fpe, Pu, Mu, Vu, embodied
"""
catalog = CSV.read(joinpath(@__DIR__,"Outputs/output_static.csv"), DataFrame);
sort!(catalog, [:carbon, :fc′, :as, :ec])

#load demands into a dictionary
open(joinpath(@__DIR__,"json/test_input.json"), "r") do f
    global demands = DataFrame(JSON.parse(f, dicttype=Dict{String,Any}))
    ns = size(demands)[1]
    demands[!,:idx] = 1:ns
end

#python used 0 index, here, we shift those by 1.
demands[!,"e_idx"] .+= 1
demands[!, "s_idx"] .+=1

#properly label the element index. Now there are repetitions.
#Need to generate a new version that does not repeat.
global e_idx = 1 
for i in 1:size(demands)[1]
    if i !=1
        demands[i-1, :e_idx] = e_idx
        if demands[i,:s_idx] < demands[i-1,:s_idx]
            global e_idx +=1 
        end
        
    end
    if i == size(demands)[1]
        demands[i, :e_idx] = e_idx
    end
end

println(demands)
# sort!(demands, [:e_idx, :s_idx])



# function match_demands(demands, catalog)

#map from element idx to section idx.
elements_to_sections = Dict(k=> Int[] for k in unique(demands[!,"e_idx"]))

#count total number of sections and elements
ns = size(demands)[1]
ne = unique(demands[!,:e_idx]) 

#number of available choices
nc = size(catalog,1)

#map between demands and indx of the feasible section they have
output_results = Dict{Int64, Vector{Int64}}()

#go through each section and filter the feasible designs from the catalog.
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
    x4<= ec_max*2, 
    catalog
    )

    if size(feasible_sections)[1] == 0
        println("No results found for section $i: element $en")
        output_results[i] = []
        # println(outr)
    else
        output_results[i] = feasible_sections[!,:ID]
        # println(outr)
    end
end

# return output_results
# end

# output_results = match_demands(demands,catalog)

"""
Find the optimum result for each element.
    
    !! not optimum
For the same element, will use the same fc′ steel size and post tensioning stress.

"""
#function find_optimum(output_results, elements_to_sections, demands)
ns = size(demands)[1]
ne = unique(demands[!,:e_idx]) #python starts at 0
element_designs = Dict(k=> [[]] for k in unique(demands[!,"e_idx"]))
#find fc′, as, and fpe that appear in all sections in an element.
for i in ne #loop each element
    println("working on element $i out of $(length(ne)) elements")
    sections = elements_to_sections[i]
    #count number of sections 
    local ns = length(sections)

    #start from the middle-ish
    mid = div(ns,2)

    #get the feasible designs for the middle section
    feasible_idx = output_results[sections[mid]]
    
    sub_catalog = sort!(catalog[feasible_idx, :], [:carbon,:ec])

    #now, loop each design in the sub catalog, see if as and fpe are available in all sections.
    #if not, remove that design from the sub catalog.
    #if yes, keep it.

    for d in eachrow(sub_catalog)
        # all_fc′ = true
        all_as = true
        all_fpe = true
        for s in sections
            #check if the design is available in that section.
            #if not, remove it from the sub catalog.
            #if yes, keep it.
            # if !(d[:fc′] ∈ catalog[output_results[s], :fc′])
            #     all_fc′ = false
            # end
            if !(d[:as] ∈ catalog[output_results[s], :as])
                all_as = false
            end
            if !(d[:fpe] ∈ catalog[output_results[s], :fpe])
                all_fpe = false
            end
        end
        if !(all_as && all_fpe)
            println("before ",length(sub_catalog))
            filter!(x->x!=d, sub_catalog)
            println("after ",length(sub_catalog))
        end
    end

    sort!(sub_catalog, [:carbon, :fpe, :as, :ec])
    #get the first one, they will appear in the entire thing anyway.
    this_fpe = sub_catalog[1,:fpe]
    this_as = sub_catalog[1, :as]

    section_designs = Vector{Vector}(undef, ns)
    for is in eachindex(elements_to_sections[i])
        #current section index
        s = elements_to_sections[i][is]

        feasible_idx = output_results[s]
        sub_catalog = catalog[feasible_idx, :]

        fpe_as(fpe::Float64, as::Float64) = fpe == this_fpe && as == this_as

        this_catalog = filter([:fpe, :as] => fpe_as , catalog[output_results[s],:])

        sort!(this_catalog, [:carbon, :ec])


        
        #get the first one, it's the best.
        select_ID= this_catalog[1,:ID]
        #find lowest e for this one.
        section_designs[is] = collect(catalog[select_ID,:])
        println(section_designs[is])
        end
element_designs[i] = section_designs

end

# final_designs = Vector{Vector}(undef, length(element_designs))
# for i in 1:length(element_designs) 
#     #just select the first one to design.
#     final_designs[i] = Array{Float64,1}(element_designs[i][1,:])
# end


# final_designs2 = Vector{Vector}(undef, length(element_designs))
# for i in 1:length(element_designs)
#     sections = elements_to_sections[i]
#     fc′s = unique()
#     ass  =
#     fpes =
#     s_idx = 2
#     while s_idx != length(sections)


#     for s in sections 
        

