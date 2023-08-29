using JSON
using PlotlyJS

# open(joinpath(@__DIR__, "dummy_28_8.json"), "r") do f #"input_2023_08_25.json"), "r") do f
#     global data = JSON.parse(f, dicttype=Dict{String,Any})
# end


function plotforces(data::Vector{Any}; cat = "mu", e = 1)
#collect total number of elements
ne = []
for i in eachindex(data)
    nei = Int(data[i]["e_idx"])
    println(nei)
    if !(nei in ne)
        push!(ne, nei)
    end
end

#now, plot by section

#element number 

# e = 1
x = []
y = []
xpos = 0
for i in eachindex(data)
    if Int(data[i]["e_idx"]) == e
        push!(x, xpos)
        push!(y, data[i][cat])
        xpos += 0.5
    end

    
end

x1 = x
y1 = y
trace1 = PlotlyJS.scatter(; x = x1 , y = y1 , mode = "lines+markers", name = "element $e $cat")
layout = Layout(;title="element $e ($cat)")
PlotlyJS.plot(trace1, layout)
end

# plotforces(data)