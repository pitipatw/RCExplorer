using CSV, DataFrames
using Interpolations

include("pixelgeo.jl")

"""
Get the depth and centroid of the section given eval points and target area
This is for the full points evaluation

    Todo, Beam or Column -> load the right one

    #filename template
# pixel_typesoflayup_dates.csv

#Beam
# pixel_y3-L-t-Lc.csv

#Column
# pixel_x2-L-t-Lc.csv
# pixel_x4-L-t-Lc.csv

"""
function getprop(target_a::Float64, L::Float64, t::Float64, Lc::Float64;
    test=false, type="Beam")

    @assert target_a >= 0
    # check file in "sections" folder for a file name
    # "pixel_$L_$t_$Lc.csv"
    if test
        filename = "dummy"
    else
        if type == "Beam"
            filename = "pixel_y3-$L-$t-$Lc"

        elseif type == "Column"
            println("Underconstruction...")

            #either 
            filename = "pixel_x2-$L-$t-$Lc"

            #or 
            filename = "pixel_x4-$L-$t-$Lc"
        else
            println("Wrong type")
        end
    end

    filename = replace(filename, "." => "_")
    fullpath = joinpath(@__DIR__, "sections", filename * ".csv")

    if isfile(fullpath)
        data = Matrix(CSV.read(fullpath, header=false, DataFrame))
    else
        println("File not found, creating a new one...")
        dx = 0.5
        dy = 0.5


        if type == "Beam"
            nodes = fullpixel(L, t, Lc)
            pts = fillpoints(nodes, dx, dy)
            pixelpts = pts[pointsinpixel(nodes, pts), :]
            total_area = dx * dy * length(pixelpts[:, 1])

            y_top = maximum(nodes[:, 2])
            y_bot = minimum(nodes[:, 2])
            if target_a > total_area
                depth = y_top - y_bot
                cgcomp = 0.0
                return depth, cgcomp
            end

            if target_a >= 0
                ub = y_top - y_bot
                lb = 0.0
                depth = (lb + ub) / 2 #initializing a variable
                counter = 0
                global ys = pixelpts[:, 2]
                ys_single = unique(ys)
                out = Matrix{Float64}(undef, length(ys_single), 3)
                for i in eachindex(ys_single)
                    yi = ys_single[length(ys_single)-i+1]
                    # println(yi)
                    # yi = ys_single[i]
                    # c_pos = y_top - depth
                    chk = ys .> yi
                    com_pts = pixelpts[chk, :]
                    ydx = ys[chk] .* (dx * dy)
                    # y2dx = ys[chk] .^ 2 .* (dx * dy)
                    area = dx * dy * size(com_pts)[1]
                    # inertia = sum(y2dx)
                    # @show area
                    # @show sum(ydx)
                    if area == 0
                        cg = 0
                    else
                        cg = sum(ydx) / area
                    end
                    # println(area)
                    out[i, :] = [yi, area, cg] # inertia]

                end

                CSV.write("sections//" * filename * ".csv", DataFrame(out, :auto), header=false)
                println("File created.")
            else
                println("Error")
                return NaN, NaN
            end

        elseif type == "Column"
            println("You are in column")
            #nodes will be array, either 2 or 4
            # will work on them separately, then combine them
            nodes = fullpixel(L, t, Lc)
        else
            println("Wrong type")
        end


    end

    data = CSV.read("sections//" * filename * ".csv", header=false, DataFrame)
    if target_a == 0
        return maximum(data[:, 2])
    else
        # println(data)
        A = linear_interpolation(data[:, 2], data[:, 1])
        cgy = linear_interpolation(data[:, 2], data[:, 3])
        # I = linear_interpolation(data[:, 2], data[:, 4])
        # I = linear_interpolation(data[:,1], data[:,3])

        maxA = maximum(data[:, 2])
        minA = minimum(data[:, 2])



        depth = A(target_a)
        cgcomp = cgy(target_a)
        return depth, cgcomp
    end

end


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
# function secprop(eval_pts::Matrix{Float64}, c::Float64; dx=1.0, dy=1.0)
#     #find moment of inertia of the point related to an axis y = c
#     # and cgy.
#     area = dx * dy * size(eval_pts)[1]
#     I = Vector{Float64}(undef, size(eval_pts)[1])
#     # Cgx = Vector{Float64}(undef, size(eval_pts)[1]) #Not interested now
#     Cgy = Vector{Float64}(undef, size(eval_pts)[1])
#     dxdy = dx * dy
#     area = size(eval_pts)[1] * dxdy
#     # println("dx: ", dx, " dy: ", dy)
#     # println("Area: ", area)

#     # @time @Threads.threads 
#     for i = 1:size(eval_pts)[1] #could do in strip
#         # x = eval_pts[i,1]
#         y = eval_pts[i, 2]
#         r = (y - c)
#         I[i] = r^2 * dxdy
#         # Cgx[i] = x*dxdy
#         Cgy[i] = y * dxdy
#     end
#     # cgx = sum(Cgx)
#     cgy = sum(Cgy) / area
#     inertia = sum(I)
#     return (area, inertia, cgy)
# end
