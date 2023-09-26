using Makie, GLMakie
using GeometricalPredicates
include("pixelgeo.jl")
include("sectionproperties.jl")

function qplot(x,y)
    f1 = Figure(resolution = (800, 600))
    ax1 = Axis(f1[1, 1], aspect = DataAspect())
    p1 = scatter!(ax1, x,y, color = :red, markersize = 0.5)
    return f1
end
L = 150
t = 10
Lc = 30
nodes = fullpixel(L, t, Lc)
qplot(nodes[:,1], nodes[:,2])
dx = 1
dy = 1
gridpts = fillpoints(nodes, dx, dy)
qplot(gridpts[:,1], gridpts[:,2])
pixelpts = gridpts[pointsinpixel(nodes, gridpts), :]
qplot(pixelpts[:,1], pixelpts[:,2])
I, cg = secprop(pixelpts, 0.0)

x_s = Vector{Float64}()
val_s = Vector{Float64}()
I_s = Vector{Float64}()
val_s_change = Vector{Float64}()
I_s_change = Vector{Float64}()
d_s = Vector{Float64}()
d_s_change = Vector{Float64}()
global dx = 1 
global counter = 0
while true
    global dx
    global dy = dx

    @show dx,dy
    gridpts = fillpoints(nodes, dx, dy)

    # println("pointsinpixel")
    #slow here
    @time pixelpts = gridpts[pointsinpixel(nodes, gridpts), :]

    ytop = maximum(pixelpts[:, 2])
    ybot = minimum(pixelpts[:, 2])


    @time area ,I, cg = secprop(pixelpts, 0.0, dx = dx, dy = dy)
    acomp = 5260.0
    @time depth, chk = getdepth(pixelpts, acomp, [ytop, ybot], dx = dx, dy = dy)
    counter +=1
    if counter == 1 
        area_change = 0 
        I_change = 0
        depth_change = 0
    else
    area_change = abs(area - val_s[end])/val_s[end]
    I_change = abs(I - I_s[end])/I_s[end]
    depth_change = abs(depth - d_s[end])/d_s[end]
    end

    push!(x_s, dx)
    push!(val_s, area)
    push!(I_s, I)
    push!(val_s_change, area_change)
    push!(I_s_change, I_change)
    push!(d_s, depth)
    push!(d_s_change, depth_change)

    if  dx < 0.05
        break
    end
    dx = dx/1.5
end

f2 = Figure(resolution = (800,600))
ax2 = Axis(f2[1,1], xlabel = "dx", ylabel = "area")
ax3 = Axis(f2[1,2], xlabel = "dx", ylabel = "Inertia")
ax4 = Axis(f2[2,1], xlabel = "dx", ylabel = "area_change")
ax5 = Axis(f2[2,2], xlabel = "dx", ylabel = "I_change")
ax6 = Axis(f2[3,1], xlabel = "dx", ylabel = "depth")
ax7 = Axis(f2[3,2], xlabel = "dx", ylabel = "depth_change")
p2 = scatter!(ax2, x_s, val_s, color = :blue)
p3 = scatter!(ax3, x_s, I_s, color = :blue)
p4 = scatter!(ax4, x_s, val_s_change, color = :blue)
p5 = scatter!(ax5, x_s, I_s_change, color = :blue)
p6 = scatter!(ax6, x_s, d_s, color = :blue)
p7 = scatter!(ax7, x_s, d_s_change, color = :blue)

f2


save( "dx_all.png",f2)
#using dx = 0.25

grid(ranges::NTuple{N, <: AbstractRange}) where N = GeometryTypes.Point.(Iterators.product(ranges...))
x = 0:0.1:1
y = 0:0.1:1
xy =grid((x,y))

xy[:,1]

poly = Polygon()
inpolygon(poly, Point(1.1,1.1)) 