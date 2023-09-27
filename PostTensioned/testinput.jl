# using Makie, GLMakie
using JSON
function demands(x::Float64,P::Float64, Ls::Float64)
    if x<= Ls
        vd = P/2
        md = P*x/2

    elseif Ls <= x <= 2*Ls
        vd = 0.0
        md = P*Ls/2
    elseif x >= 2*Ls
        vd = -P/2
        md = P*(3*Ls-x)/2
    else
        println("x = $x is out of bound")
    end

    return [vd, md]
end



# f1 = Figure(resolution = (800, 600))
# ax1 = Axis(f1[1,1]) 
# ax2  = Axis(f1[1,2])
# Ls = 20.0
# x = 0:1:3*Ls


# vds = [demands(x[i], 100.0, Ls)[1] for i in eachindex(x) ]
# mds = [demands(x[i], 100.0, Ls)[2] for i in eachindex(x) ]

# scatter!(ax1, x, vds, color = :red)
# scatter!(ax2 , x, mds, color = :blue)

include("load.jl")

Ls1 = 2000.0 #mm
Ls2 = 1000. #mm
Lss = [Ls1, Ls2]

println("$w kN/m2 ")
p1 = w*3*Ls1^2/2/1e6
p2 = w*3*Ls2^2/2/1e6
ps = [p1, p2]
x1 = 0:500.:3*Ls1
x2 = 0:500.:3*Ls2
xs = [x1, x2]
vds1 = [demands(x1[i], p1, Ls1)[1] for i in eachindex(x1)]
mds1 = [demands(x1[i], p1, Ls1)[2]/1000 for i in eachindex(x1)]

vds2 = [demands(x2[i], p2, Ls2)[1] for i in eachindex(x2)]
mds2 = [demands(x2[i], p2, Ls2)[2]/1000 for i in eachindex(x2)]
ecs = [0.8, 1.2]
types = ["Beam", "Beam"]
#create json. 
data = []
for i in 1:2
    vds1 = [demands(xs[i][j], ps[i], Lss[i])[1] for j in eachindex(xs[i])]
    mds1 = [demands(xs[i][j], ps[i], Lss[i])[2] for j in eachindex(xs[i])]/1000
    for j in eachindex(xs[i])
        tempj = Dict{String, Any}()
        tempj["pu"] = 100.0
        tempj["vu"] = vds1[j]
        tempj["mu"] = mds1[j]
        tempj["ec_max"]=  ecs[i]
        tempj["L"]=  192.0
        tempj["t"]=  10.0
        tempj["Lc"]= 20.0
        tempj["type"]= types[i]
        tempj["e_idx"] = i

        push!(data, tempj)
    end         
end

jsonfile = JSON.json(data)
open(joinpath(@__DIR__,"dummy_28_8.json"), "w") do f
    write(f, jsonfile)

end