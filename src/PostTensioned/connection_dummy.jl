using CSV, DataFrames, JSON
using Dates
date = Dates.today()
"""
catalog format
fc', as, ec, fpe, Pu, Mu, Vu, embodied
"""
catalog = CSV.read(joinpath(@__DIR__,"Outputs\\output_$date.csv"), DataFrame)

#test input
open(joinpath(@__DIR__,"JSON\\small_test_input.json"), "r") do f
    global demands = DataFrame(JSON.parse(f, dicttype=Dict{String,Any}))
    ns = size(demands)[1]
    demands[!,:idx] = 1:ns
end

function match_demands(demands, catalog)
#goes in a loop
ns = size(demands)[1]
ne = maximum(demands[!,:e_idx])+1 #python starts at 0

#number of available choices
nc = size(catalog,1)
output_results = Dict{Int64, Vector{Int64}}()

#go through each section.
for i = 1:ns
    pu = demands[i,"pu"]
    mu = demands[i,"mu"]
    vu = demands[i,"vu"]
    ec_max = demands[i,"ec_max"]
    
    # # @show repeat([pu, mu, vu], outer = (1,nc))'
    # if demands[i,"type"] == "primary"
    #     #calculate section with 3 pieces
    #     #have to add 
    #     np = 3
    #     #load csv with np suffix
    #     #or use the catalog that was loaded intiailly.
    #     cin = CSV.read("results//output_$date.csv", DataFrame)
    # elseif data[i]["type"] == "Column"
    #     #calculate section with 4 or 2 pieces
    #     np = 4
    #     #load csv with np suffix
    #     # cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))
    #     np = 2
    #     #load csv with np suffix
    #     # cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))


    #     cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))
    # end

    #I found that this might be slower than looping... here : https://julialang.org/blog/2013/09/fast-numeric/
    global feasible_sections = filter([:Pu,:Mu,:Vu,:ec] => (x1,x2,x3,x4) -> 
    x1>pu &&
    x2>mu &&
    x3>vu &&
    x4<= ec_max, catalog)

    if size(feasible_sections)[1] == 0
        println("No results found for section $i")
        output_results[i] = []
        # println(outr)
    else
        output_results[i] = feasible_sections[!,:ID]
        # println(outr)
    end
end

return output_results
end

output_results = match_demands(demands,catalog)

"""
Find the optimum result for each element. 
For the same element, will use the same fc′ and steel size. 

"""
#function find_optimum(output_results
ns = size(demands)[1]
ne = maximum(demands[!,:e_idx])+1 #python starts at 0

# for i in 1:ne
    i = 1
    #sections index that are with that element.
    sections = filter(:e_idx => x-> x==i, demands)
    println(i," ",demands[i,:e_idx])
    println(sections)
    sections[!, :idx]
    println(getindex.(Ref(output_results) , sections[!,:idx] ))
    unique(fc′)
    unique(as)

    for i in fc′ unique
        if length(filter(this fc′))
        if that length == total section (happens all) 
            save it.

    do the same thing for as. 
    
    get the design that match both cases. (have fc′ and as across entire beam.)

    end
    With those design, sort by gwp. 
    select the lowest gwp .

    save the  design to the eleement 
    Dict( i -> [vector of indices])
    #get result

# end

    fesible_sections 
select the same fc′ and steel size that shows across the elements, 
find the lowest

outvod = Vector{Vector{Dict}}(undef, size(outr,1))
for i = axes(outr,1)
    temp = Vector{Dict}(undef, size(outr[i],1))
    for j = axes(outr[i],1)
        temp[j] = Dict( "fc" => outr[i][j,1],
                        "as" => outr[i][j,2],
                        "ec" => outr[i][j,3],
                        "fpe"=> outr[i][j,4],
                        "pu" => outr[i][j,5],
                        "mu" => outr[i][j,6],
                        "vu" => outr[i][j,7],
                        "embodied"=> outr[i][j,8],
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
open(joinpath(@__DIR__,"output_"*filename), "w") do f
    write(f, jsonfile)
    println("output_"*filename*" written succesfully")

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
