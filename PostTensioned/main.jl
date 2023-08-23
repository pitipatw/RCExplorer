# module PostTen
using JSON
using HTTP
using Dates
using CSV

include("pixelgeo.jl") #generating Pixel geometries
include("sectionproperties.jl")
include("calstr.jl") #calculating strength
include("getterrain.jl")


"""
cin format
fc', as, ec, fpe, pu, mu, vu, embodied
"""


cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))
#HTTP connection
function main(cin)
    #initialize the server
    # try
        server = WebSockets.listen!("127.0.0.1", 2000) do ws
            for msg in ws
                println("Hello World")
                today = string(Dates.today())
                today = replace(today, "-" => "_")
                filename = today*".json"
                data = JSON.parse(msg, dicttype=Dict{String,Any})

                open(joinpath(@__DIR__, "input_"*filename), "w") do f
                    write(f, msg)
                end
                println("input_"*filename*" written succesfully")
                
                #load the data terrain

                #goes in a loop
                ns = length(data)
                ne = 20 #somehow get the number of elements
                # nc = 4 #number of available choices
                nc = size(cin,1)
                global outr = Vector{Matrix{Float64}}()
                # for si = 1:ns
                for i = 1:ns
                    # c1 = Vector{Float64}(undef, ns)
                    # c2 = Vector{Float64}(undef, ne)

                    pu = parse(Float64,data[i]["pu"])
                    mu = parse(Float64,data[i]["mu"])
                    vu = parse(Float64,data[i]["vu"])
                    ec_max = parse(Float64,data[i]["ec_max"])
                    
                    # @show repeat([pu, mu, vu], outer = (1,nc))'
                    if data[i]["t"] == "Beam"
                        #calculate section with 3 pieces
                        #have to add 
                        np = 3
                        #load csv with np suffix

                        cin = Matrix(CSV.read("results//output_$date.csv", DataFrame))
                    elseif data[i]["t"] == "Column"
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
                        # println(outr)
                    end
                    
                end
                # println(outr)

                #here, turn outr into a dictionary, for json file 
                #just loop them
                outvod = Vector{Vector{Dict}}(undef, size(outr,1))
                for i = axes(outr,1)
                    temp = Vector{Dict}(undef, size(outr[i],1))
                    for j =axes(outr[i],1)
                        temp[j] = Dict( "fc" => outr[i][j,1], 
                                        "as" => outr[i][j,2],
                                        "ec" => outr[i][j,3],
                                        "fpe"=> outr[i][j,4], 
                                        "pu" => outr[i][j,5], 
                                        "mu" => outr[i][j,6], 
                                        "vu" => outr[i][j,7], 
                                        "embodied" => outr[i][j,8],
                                        "element" => data[i]["e_idx"],

                                        )
                    end
                    outvod[i] = temp
                end

                #add the last spot, for optimum choice for the section
                #What is optimum? 
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
            end
        end
    # catch 
    #     println("Error")
    #     println("Closing the server")
    #     WebSockets.close(server)
    #     return server
    # end
end

close(server)
server = main(cin)
close(server)


#close(server)
 


#get the data
filename = PostTen.initialize()

file = open(joinpath(@__DIR__,filename) )
data = JSON.parse(file)
#data is a dictionary with keys
section : {L , t, Lc}
ec_max
demands : {Mu, Vu, Pu}

###
#a function that input L, t,Lc and get area, inertia and cg out.

#save the csv file.

#from now on, read the file.

CSVfilename = "pixel_$L_$t_$Lc.csv"
# a function that read and interpolate points between files.

#calculation results 
ac = 400.0 #total cross section area of the section


#constant parameters
Ep = 200_000

#loops
#full
"""
dx = dy = 0.25
n for pixel = 10
"""
function test1()
    #  range_fc′ = 28:7:56
    #  range_as = [99.0 , 140.0]
    #  range_ec = 0.5:0.1:ec_max
    #  range_fpe = (0.1:0.1:0.7) * 1860.0
#test
range_fc′ = 28
range_as = 99.0
range_ec = 0.5
range_fpe = 186.0


total_s = length(range_fc′) * length(range_as) * length(range_ec) * length(range_fpe)
results = Matrix{Float64}(undef,4, total_s)
     #we will loop through these three parameters and get the results.
# with constant cross section properties.
for idx_fc′ in eachindex(range_fc′)
    for idx_as in eachindex(range_as)
        for idx_ec in eachindex(range_ec)
            for idx_fpe in eachindex(range_fpe)
                global fc′ = range_fc′[idx_fc′]
                global as = range_as[idx_as]
                global ec = range_ec[idx_ec]
                global fpe = range_fpe[idx_fpe]


                pu, mu, vu, valid = calstr()
                idx = map(idx_fc′ , idx_as, idx_ec, idx_fpe)


            end
        end
    end
end
end