using DataFrames
using GLMakie, Makie
using kjlMakie
set_theme!(kjl_light)
# using PlotlyJS

include("Definitions.jl")
function getρ(Mu::Float64, fc′::Float64, b::Float64,d::Float64; fy::Float64=420.0,ϕ = 0.9)
    αf = fc′/1.18/fy
    if  αf^2 - (Mu/(ϕ*b*d^2)*2*αf/fy) > 0
        ρ = αf - sqrt(αf^2 - (Mu/(ϕ*b*d^2)*2*αf/fy))
    else 
        ρ = 0.0
    end

    return ρ
end

fc′s = 28.0:1:55.0
Mus = 1e6:1e6:1e8
ds = 200.:25:500.
bd_ratios = 0.5:0.25:1.0

fc′_his = Vector{Float64}()
Mu_his = Vector{Float64}()
d_his = Vector{Float64}()
bd_ratio_his = Vector{Float64}()
ρ_his = Vector{Float64}()

count = 0
t = prod(length.([fc′s,Mus,ds,bd_ratios]))

println("Total Points: $t")
for fc′ in fc′s 
    for Mu in Mus
        for d in ds
            for bd_ratio in bd_ratios
                count +=1
                b = bd_ratio*d
                ρ = getρ(Mu,fc′,b,d)
                push!(fc′_his , fc′)
                push!(Mu_his, Mu)
                push!(d_his,d)
                push!(bd_ratio_his, bd_ratio)
                push!(ρ_his, ρ)
            end
        end
    end
end

catalog = DataFrame(ID = 1:count,
                    fc′ =fc′_his, 
                    Mu = Mu_his,
                    d = d_his,
                    bd_ratio = bd_ratio_his,
                    ρ = ρ_his)

catalog[!, :area] = catalog[!,:d].^2 .*catalog[!, :bd_ratio]
catalog[!, :steel_area] = catalog[!, :area].*catalog[!, :ρ]

catalog[!, :eec_fc′] = fc′_to_eec.(catalog[!, :fc′])

catalog[!, :gwp] = catalog[!,:eec_fc′].*catalog[!,:area]/1e6 + (1.99 .- catalog[!,:eec_fc′]).*catalog[!,:steel_area]/1e6 

catalog = filter(:ρ => x-> x > 0, catalog)

f1 = Figure(resolution = (600,600))
ax1 = Axis(f1[1,1], title = "Simplified Plot"
        ,xlabel = "fc′ [MPa]", ylabel = "gwp [kgCO2e/kg.m]")
s1 = scatter!(ax1, catalog[!, :fc′], catalog[!,:gwp], color = catalog[!, :Mu], strokewidth=0)
Colorbar(f1[1,3], s1, label = "Mu", labelrotation =0)

# selected_fc′ = Observable{Any}(0.0)

# min_fc′ = minimum(fc′s)
# max_fc′ = maximum(fc′s)
# slider1 = Slider(f1[1,2], range = fc′s, startvalue = min_fc′,horizontal = false)
# slider1 = Slider(f1[1,2], range = ds, startvalue = minimum(ds),horizontal = false)
slider1 = Slider(f1[2,2], range = Mus, startvalue = minimum(Mus),horizontal = false)
slider2 = Slider(f1[2,3], range = ds, startvalue = minimum(ds),horizontal = false)

# x = Observable(catalog[!, :area])
x = Observable(Point2f())
y = Observable(catalog[!, :gwp])
z = Observable(catalog[!, :fc′])
title_name = Observable("String")
filtered1 = lift(slider1.value) do n
    new_cat = filter(:Mu => x-> x == n, catalog)
    # x[] = Point2f.(vcat.(new_cat[!,:area], new_cat[!,:gwp]))
    x[] = Point2f.(new_cat[!,:area], new_cat[!,:gwp])
    y[] = new_cat[!,:gwp]
    z[] = new_cat[!,:fc′]
    title_name[] = string(n)
    println(size(new_cat))
    return new_cat[!, :Mu], new_cat[!, :gwp]
end

ax2 = Axis(f1[2,1]
        ,xlabel = "fc′ [MPa]", ylabel = "gwp [kgCO2e/kg.m]")

center_pos = (maximum(fc′s) + minimum(fc′s))/2
ver_pos = maximum(catalog[!, :gwp])/2

s3 = scatter!(ax2, catalog[!, :fc′], catalog[!,:gwp], color = :grey, strokewidth=0)
s2 = scatter!(ax2,z, y, color= x,strokewidth = 0 )
text!(ax2,50, 0.04,text = title_name)

# Colorbar(f1[1,2], s1, label = "fc′", labelrotation =0)