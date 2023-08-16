using CSV
using Interpolations

include("pixelgeo.jl")
"""
Get inertia and cg of the given section
inputs:
    eval_pts: matrix of grid points to evaluate
    c: y position of the neural axis
    dx: x spacing
    dy: y spacing
outputs: 
    area : area of the section
    inertia: moment of inertia of the section around y = c
    cgy: y position of the centroid
"""
function secprop(eval_pts::Matrix{Float64} , c::Float64; dx = 1.0, dy = 1.0)
    #find moment of inertia of the point related to an axis y = c
    # and cgy.
    area = dx*dy*size(eval_pts)[1]
    I = Vector{Float64}(undef, size(eval_pts)[1])
    # Cgx = Vector{Float64}(undef, size(eval_pts)[1]) #Not interested now
    Cgy = Vector{Float64}(undef, size(eval_pts)[1])
    dxdy = dx*dy
    area = size(eval_pts)[1]*dxdy
    # println("dx: ", dx, " dy: ", dy)
    # println("Area: ", area)

    # @time @Threads.threads 
    for i =1:size(eval_pts)[1] #could do in strip
        # x = eval_pts[i,1]
        y = eval_pts[i,2]
        r = (y-c)
        I[i] = r^2*dxdy
        # Cgx[i] = x*dxdy
        Cgy[i] = y*dxdy
    end
    # cgx = sum(Cgx)
    cgy = sum(Cgy)/area
    inertia = sum(I)
    return (area, inertia, cgy)
end

"""
Get the depth and centroid of the section given eval points and target area
This is for the full points evaluation
"""
function getprop(target_a::Float64 ; 
    test = false,
    L = L,
    t = t,
    Lc = Lc,
    )

    # check file in "sections" folder for a file name
    # "pixel_$L_$t_$Lc.csv"
    if test
        filename = "dummy.csv"
        fullpath = joinpath(@__DIR__, "sections", filename)
    else
        filename = "pixel-$L-$t-$Lc.csv"
        fullpath = joinpath(@__DIR__, "sections", filename)
    end

    if isfile(fullpath) 
        data = Matrix(CSV.read(fullpath, header=false, DataFrame))
    else 
        println("File not found, creating a new one...")
        dx = 0.5
        dy = 0.5
        nodes = fullpixel(L, t, Lc)
        pts = fillpoints(nodes, dx,dy)
        pixelpts = pts[pointsinpixel(nodes,pts),:]
        total_area = dx*dy*length(pixelpts[:,1])

y_top = maximum(nodes[:,2])
y_bot = minimum(nodes[:,2])
ub = y_top - y_bot
lb = 0.0
depth = (lb + ub) / 2 #initializing a variable
counter = 0
global  ys = pixelpts[:, 2]
ys_single = unique(ys)
out = Matrix{Float64}(undef ,length(ys_single),3)
for i in eachindex(ys_single)
    yi = ys_single[i]
    # c_pos = y_top - depth
    chk = ys .> yi
    com_pts = pixelpts[chk, :]
    ydx = ys[chk].*(dx*dy)
    
    area = dx * dy * size(com_pts)[1]
    cg = sum(ydx)/area
    out[i,:] = [yi, area, cg]

end

CSV.write("pixel-$L-$t-$Lc.csv", DataFrame(out ,:auto), header = false)
data = CSV.read("pixel-$L-$t-$Lc.csv", header = false, DataFrame)


        # CSV.write(fullpath, data)


    end

    A = interpolate(data[:,2], data[:,1])
    cgy = linear_interpolation(data[:,2], data[:,3])
    # I = linear_interpolation(data[:,1], data[:,3])

    depth = A(target_a)
    cgcomp = cgy(depth)

    return depth , cgcomp
end

getdepth(43.0, test=true)