module PixelGeometry
using LinearAlgebra
using GeometryBasics
using Makie, GLMakie
"""
    makepixel(L::Real, t::Real, Lc::Real; n = 10)
L = length of pixel arm
t = thickness
Lc = straight region of pixel (length before arc)
n = number of discretizations for arc
"""
function makepixel(L::Real, t::Real, Lc::Real; n=10)
    #constants
    θ = pi / 6
    ϕ = pi / 3
    psirange = range(0, ϕ, n)
    #origin
    p1 = [0.0, 0.0]
    # first set
    p2 = p1 .+ [0.0, -L]
    p2′ = p1 .+ L .* [cos(θ), sin(θ)]
    #second set
    p3 = p2 .+ [t, 0.0]
    p3′ = p2′ + t .* [cos(ϕ), -sin(ϕ)]
    #third set
    p4 = p3 .+ [0.0, Lc]
    p4′ = p3′ .+ Lc .* [-cos(θ), -sin(θ)]
    #arc
    v4 = p4′ .- p4
    #radius
    r = norm(v4) / cos(ϕ) / 2
    #arc center
    p5 = p4 .+ [r, 0.0]
    arcs = [p5 .+ r .* [-cos(ang), sin(ang)] for ang in psirange]
    points = [p1, p2, p3, p4, arcs..., p4′, p3′, p2′]
    return points
end


function main()
    points = makepixel(150, 10, 10)
    # Change points from a vector of array to an array
    point_matrix = Matrix{Float64}(undef, size(points)[1], 2)
    for row in 1:size(point_matrix)[1]
        point_matrix[row, :] = points[row]
    end
    # change all the points to opposite sign
    negative_points = -1 * (point_matrix)

    # take original numbers for y and opposite sign numbers for x to get a reflection 
    new_points = Array{Array{Float64,1},1}()
    for i in 1:size(point_matrix)[1]
        x = negative_points[i, 1]
        y = point_matrix[i, 2]
        push!(new_points, [x, y])
    end


    ## get a top pixel piece (rotation to top)
    # using rotation matrix
    θ = 120.0
    # rotation_matrix = [[cosd(θ), (-1*sind(θ))] [sind(θ) ,cosd(θ)]]
    rotation_matrix = [cosd(θ) -sind(θ) ; sind(θ) cosd(θ)]
    new_points3 = Array{Array{Float64,1},1}()
    # println(point_matrix)
    # println(point_matrix[3, :])
    # example_rotation = rotation_matrix .* point_matrix[3, :]
    # # println(example_rotation)
    #     y= sum(example_rotation[1])
    #     x= sum(example_rotation[2])
    #     println(x)
    #     println(y)
    for row in 1:size(point_matrix)[1]
        rotated_points = rotation_matrix * point_matrix[row, :]
        x = rotated_points[1]
        y = rotated_points[2]
        push!(new_points3, [x, y])
    end
    println(new_points3)


    #getting the top piece(rotation to top) from Keith & Pitipat's script

    #extract x and y from points
    ptx1 = [i[1] for i in points]
    pty1 = [i[2] for i in points]
    #remove first point (0.0)
    ptx1 = ptx1[2:end]
    pty1 = pty1[2:end]
    # ptx = vcat(ptx1, -ptx1)
    # pty = vcat(pty1, pty1)

    ptx = ptx1
    pty = pty1
    nodes = [ptx pty]
    #rotate to the top
    new_points2 = Array{Array{Float64,1},1}()
    # draw a full pixelframe section
    for i = 1:size(nodes)[1]
        x = nodes[i, 1]
        y = nodes[i, 2]
        r = sqrt(x^2 + y^2)
        θ = atand(y / x)
        newθ = θ + 120.0
        newx = r * cosd(newθ)
        newy = r * sind(newθ)
        push!(new_points2, [newx, newy])
    end
    println(new_points2)

    # f2 = Figure(resolution=(600, 600))
    # ax2 = Axis(f2[1, 1], aspect=DataAspect(), xlabel="x", ylabel="y")
    # poly!(Point2.(new_points2))
    # return(f2)

    f1 = Figure(resolution=(600, 600))
    ax1 = Axis(f1[1, 1], aspect=DataAspect(), xlabel="x", ylabel="y")
    poly!(Point2.(points))
    poly!(Point2.(new_points))
    # println(new_points2)
    poly!(Point2.(new_points3))
    return f1
end
end

PixelGeometry.main()