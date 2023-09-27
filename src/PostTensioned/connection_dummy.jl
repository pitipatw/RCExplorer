"""
cin format
fc', as, ec, fpe, pu, mu, vu, embodied
"""

cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))
#HTTP connection

#initialize the server
# try
open(joinpath(@__DIR__,"dummy_28_8.json"), "r") do f
    global data = JSON.parse(f, dicttype=Dict{String,Any})
end

#load the data terrain

#goes in a loop
ns = length(data)
# ne = 20 #somehow get the number of elements
#number of available choices
nc = size(cin,1)
global outr = Vector{Matrix{Float64}}()
# for si = 1:ns
for i = 1:ns
    # c1 = Vector{Float64}(undef, ns)
    # c2 = Vector{Float64}(undef, ne)

    pu = data[i]["pu"]
    mu = data[i]["mu"]
    vu = 0 #data[i]["vu"]
    ec_max = data[i]["ec_max"]
    
    # @show repeat([pu, mu, vu], outer = (1,nc))'
    if data[i]["type"] == "Beam"
        #calculate section with 3 pieces
        #have to add 
        np = 3
        #load csv with np suffix

        cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))
    elseif data[i]["type"] == "Column"
        #calculate section with 4 or 2 pieces
        np = 4
        #load csv with np suffix
        # cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))

        np = 2
        #load csv with np suffix
        # cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))


        cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))
    end

    #I found that this might be slower than looping... here : https://julialang.org/blog/2013/09/fast-numeric/
    global c1 = cin[:,5:7] .> repeat([pu, mu, vu], outer = (1,nc))'
    # c2 = cin[:,8] .< repeat(ec_max, nc)
    cout = copy(c1) # .&& c2
    global check = vec(Bool.(prod(cout, dims=2)))
    # println(i)
    # @show sum(check)
    if sum(check) == 0 #no answer for this section
        println("No results found")
        push!(outr, zeros(1,8))
        # println(outr)
    else
        push!(outr, cin[check,:])
        println("results found")
        # println(outr)
    end
    
end
# println(outr)

#here, turn outr into a dictionary, for json file 
#just loop them
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
