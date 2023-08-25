# module PostTen
using JSON
using HTTP
using Dates
using CSV

include("pixelgeo.jl") #generating Pixel geometries
include("sectionproperties.jl")
include("calstr.jl") #calculating strength
include("getterrain.jl")
include("connection.jl")


server = main(cin)
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