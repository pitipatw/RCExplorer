# module PostTen
using JSON
using HTTP
using Dates
using CSV
#generating Pixel geometries
include("pixelgeo.jl")

include("sectionproperties.jl")
# include("calstr.jl") #calculating strength
include("catalog.jl") #was named getterrain.jl
include("connection.jl")
include("connection_dummy.jl")

#post processing
include("plotjson.jl")

#HTTP connection
function main(catalog)
    #initialize the server
    #try
    server = WebSockets.listen!("127.0.0.1", 2000) do ws
        for msg in ws
            #store the input as a csv file, label today's date.
            println("Hello World")
            today = string(Dates.today())
            today = replace(today, "-" => "_")
            filename = today * ".json"
            data = JSON.parse(msg, dicttype=Dict{String,Any})

            open(joinpath(@__DIR__, "input_" * filename), "w") do f
                write(f, msg)
            end
            println("input_" * filename * " written succesfully")

            #goes in a loop
            ns = length(data) #each section
            ne = 20 #somehow get the number of elements
            #number of available choices (nc)
            nc = size(catalog, 1)
            outr = Vector{Matrix{Float64}}()
            # for si = 1:ns
            for i = 1:ns
                #load the right section data
                # c1 = Vector{Float64}(undef, ns)
                # c2 = Vector{Float64}(undef, ne)
                L = parse(Float64, data[i]["L"])
                t = parse(Float64, data[i]["t"])
                Lc = parse(Float64, data[i]["Lc"])

                pu = parse(Float64, data[i]["pu"])
                mu = parse(Float64, data[i]["mu"])
                vu = parse(Float64, data[i]["vu"])
                ec_max = parse(Float64, data[i]["ec_max"])

                # @show repeat([pu, mu, vu], outer = (1,nc))'
                if data[i]["type"] == "Beam"
                    #calculate/load section with 3 pieces
                    #slow 
                    get_catalog(L, t, Lc)

                    # #have to add 
                    # catalog = Matrix(CSV.read("results//output_$date.csv", DataFrame))
                    # np = 3
                    # #load csv with np suffix
                    # catalog = Matrix(CSV.read("results//output_$date.csv", DataFrame))
                elseif data[i]["type"] == "Column"
                    #calculate section with 4 or 2 pieces
                    np = 4
                    #load csv with np suffix
                    # catalog = Matrix(CSV.read("results//output_$date.csv", DataFrame))

                    np = 2
                    #load csv with np suffix
                    # catalog = Matrix(CSV.read("results//output_$date.csv", DataFrame))


                    catalog = Matrix(CSV.read("results//output_$date.csv", DataFrame))
                end

                #I found that this might be slower than looping... here : https://julialang.org/blog/2013/09/fast-numeric/
                c1 = catalog[:, 5:7] .> repeat([pu, mu, vu], outer=(1, nc))'
                # c2 = catalog[:,8] .< repeat(ec_max, nc)
                cout = copy(c1) # .&& c2
                check = vec(Bool.(prod(cout, dims=2)))
                # println(i)
                # @show sum(check)
                if sum(check) == 0 #no answer for this section
                    println("No results found")
                    push!(outr, zeros(1, 8))
                    # println(outr)

                else
                    push!(outr, catalog[check, :])
                    # println(outr)
                end

            end
            # println(outr)

            #here, turn outr into a dictionary, for json file 
            #just loop them
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
                        "element" => data[i]["e_idx"],)
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
            open(joinpath(@__DIR__, "output_" * filename), "w") do f
                write(f, jsonfile)
                println("output_" * filename * " written succesfully")

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
server = main(catalog)
# close(server)



# #get the data
# filename = PostTen.initialize()

# file = open(joinpath(@__DIR__,filename) )
# data = JSON.parse(file)
# #data is a dictionary with keys
# section : {L , t, Lc}
# ec_max
# demands : {Mu, Vu, Pu}

# ###
# #a function that input L, t,Lc and get area, inertia and cg out.

# #save the csv file.

# #from now on, read the file.

# CSVfilename = "pixel_$L_$t_$Lc.csv"
# # a function that read and interpolate points between files.

# #calculation results 
# ac = 400.0 #total cross section area of the section


# #constant parameters
# Ep = 200_000

# #loops
# #full
# """
# dx = dy = 0.25
# n for pixel = 10
# """
# function test1()
#     #  range_fc′ = 28:7:56
#     #  range_as = [99.0 , 140.0]
#     #  range_ec = 0.5:0.1:ec_max
#     #  range_fpe = (0.1:0.1:0.7) * 1860.0
# #test
# range_fc′ = 28
# range_as = 99.0
# range_ec = 0.5
# range_fpe = 186.0


# total_s = length(range_fc′) * length(range_as) * length(range_ec) * length(range_fpe)
# results = Matrix{Float64}(undef,4, total_s)
#      #we will loop through these three parameters and get the results.
# # with constant cross section properties.
# for idx_fc′ in eachindex(range_fc′)
#     for idx_as in eachindex(range_as)
#         for idx_ec in eachindex(range_ec)
#             for idx_fpe in eachindex(range_fpe)
#                 global fc′ = range_fc′[idx_fc′]
#                 global as = range_as[idx_as]
#                 global ec = range_ec[idx_ec]
#                 global fpe = range_fpe[idx_fpe]


#                 pu, mu, vu, valid = calstr()
#                 idx = map(idx_fc′ , idx_as, idx_ec, idx_fpe)


#             end
#         end
#     end
# end
# end