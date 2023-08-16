using CSV, DataFrames
using Interpolations

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
Get the depth of the section given eval points and target area
This is for the full points evaluation
"""
function getdepth(target_a::Float64 ; 
    tol::Float64 = 0.1, 
    dx = 1.0, 
    dy = 1.0,
    test = false,
    L = 200.0,
    t = 20.0,
    Lc = 10.0,
    )

    # check file in "sections" folder for a file name
    # "pixel_$L_$t_$Lc.csv"
    if test
        filename = "dummy.csv"
        fullpath = joinpath(@__DIR__, "sections", filename)
    else
        filename = "pixel_$L_$t_$Lc.csv"
        fullpath = joinpath(@__DIR__, "sections", filename)
    end

    if isfile(fullpath) 
        data = Matrix(CSV.read(fullpath, header=false, DataFrame))
    else 
        println("File not found, creating a new one...")
        # data = fullpixel(L, t, Lc)
        # CSV.write(fullpath, data)
    end
    println(data[:,1])

    # I = linear_interpolation(data[:,1], data[:,3])

    depth = A(target_a)
    
    return depth
end

getdepth(43.0, test=true)