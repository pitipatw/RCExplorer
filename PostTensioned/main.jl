# module PostTen
using JSON
using HTTP
using Dates

include("pixelgeo.jl") #generating Pixel geometries
include("sectionproperties.jl")
include("calstr.jl") #calculating strength
include("getterrain.jl")


"""
cin format
fc', as, ec, fpe, pu, mu, vu, embodied
"""
cin = getterrain(test = false) 
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
                outr = Vector{Matrix{Float64}}(undef, ns)
                # for si = 1:ns
                for i = 1:ns
                    c1 = Vector{Float64}(undef, ne)
                    # c2 = Vector{Float64}(undef, ne)

                    pu = parse(Float64,data[i]["pu"])
                    mu = parse(Float64,data[i]["mu"])
                    vu = parse(Float64,data[i]["vu"])
                    ec_max = data[i]["ec_max"]
                    
                    # @show repeat([pu, mu, vu], outer = (1,nc))'
                    c1 = cin[:,5:7] .> repeat([pu, mu, vu], outer = (1,nc))'
                    # c2 = cin[:,8] .< repeat(ec_max, nc)
                    cout = copy(c1) # .&& c2
                    check = Bool.(sum(cout, dims=2))
            
                    if sum(check) == 0
                        println("No results found")
                        push!(outr, zeros(1,8))
                        
                    else
                    push!(outr, cin[check,:])
                    end
                    
                end
                println(outr)
                jsonfile = JSON.json(outr)
                HTTP.send(ws,jsonfile)
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