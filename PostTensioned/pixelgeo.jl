using LinearAlgebra
using PolygonInbounds
using GeometryTypes
using StaticArrays
"""
By Keith JL.
    makepixel(L::Real, t::Real, Lc::Real; n = 10)
L = length of pixel arm
t = thickness
Lc = straight region of pixel (length before arc)
n = number of discretizations for arc
"""
function make_pixel_geometry(L::Real, t::Real, Lc::Real; n = 10)

    #constants
    θ = pi/6
    ϕ = pi/3
    psirange = range(0, ϕ, n)

    #origin
    p1 = [0., 0.]

    # first set
    p2 = p1 .+ [0., -L]
    p2′ = p1 .+ L .* [cos(θ), sin(θ)]

    #second set
    p3 = p2 .+ [t, 0.]
    p3′ = p2′ + t .* [cos(ϕ), -sin(ϕ)]

    #third set
    p4 = p3 .+ [0., Lc]
    p4′ = p3′ .+ Lc .* [-cos(θ), -sin(θ)]

    #arc
    v4 = p4′ .- p4

    #radius
    r = norm(v4) / cos(ϕ) / 2

    #arc center
    p5 = p4 .+ [r, 0.] 

    arcs = [p5 .+ r .* [-cos(ang), sin(ang)] for ang in psirange]

    points = [p1, p2, p3, arcs..., p3′, p2′]

    return points
end

function fullpixel(L::Real, t::Real, Lc::Real; n = 10)
    g1 = make_pixel_geometry(L, t, Lc, n = n) ; 
    ptx1 = [i[1] for i in g1[1]]
    pty1 = [i[2] for i in g1[1]]
    #remove first point (0.0)
    ptx1 = ptx1[2:end]
    pty1 = pty1[2:end]
    # ptx = vcat(ptx1, -ptx1)
    # pty = vcat(pty1, pty1)
    
    ptx = ptx1
    pty = pty1

    nodes = [ptx pty]

    #rotate to the top
    newpoints1 = Matrix{Float64}(undef, size(nodes)[1], 2)
    # draw a full pixelframe section
    for i = 1:size(nodes)[1]
        x = nodes[i,1]
        y = nodes[i,2]
        r = sqrt(x^2 + y^2)
        θ = atand(y/x)

        newθ = θ + 120.0
        newx = r*cosd(newθ)
        newy = r*sind(newθ)
        newpoints1[i,:] = [newx, newy]
    end
    
    #rotate to the side (flip)
    newpoints2 = Matrix{Float64}(undef, size(nodes)[1], 2)
    # draw a full pixelframe section
    for i = 1:size(nodes)[1]
        x = nodes[i,1]
        y = nodes[i,2]
        r = sqrt(x^2 + y^2)
        θ = atand(y/x)
   
        newθ = θ + 240.0
        newx = r*cosd(newθ)
        newy = r*sind(newθ)

        newpoints2[i,:] = [newx, newy]
    end

    newnodes = vcat(nodes, newpoints1, newpoints2)

    return newnodes
end

#Will have to make a half pixel here.
#In the hope that I can just mirror that whole thing and make it faster? 
function halfpixel(L::Real, t::Real, Lc::Real; n = 10)
    println("Hang in there. I'm working on it.")
end

"""
Turn a vector of vector into matrix
"""
function vecvec_to_matrix(vecvec)
    dim1 = length(vecvec)
    dim2 = length(vecvec[1])
    my_array = zeros(Float64, dim1, dim2)
    for i in 1:dim1
        for j in 1:dim2
            my_array[i,j] = vecvec[i][j]
        end
    end
    return my_array
end

"""
fill a box that tighly confines pixel geometry with grid points, with a grid size dx, dy
"""
function fillpoints(nodes::Matrix{Float64}, dx::Real, dy::Real)

    #get bounding box
    xmin = minimum(nodes[:,1])
    xmax = maximum(nodes[:,1])
    ymin = minimum(nodes[:,2])
    ymax = maximum(nodes[:,2])

    #create a matrix of grid points.
    x = xmin:dx:xmax
    y = ymin:dy:ymax

    grid(ranges::NTuple{N, <: AbstractRange}) where N = GeometryTypes.Point.(Iterators.product(ranges...))
    points = grid((x,y))

    # @time points = vec(collect.(points))
    points = vec(points)

    points = vecvec_to_matrix(points)

    return points
end

function pointsinpixel(nodes::Matrix{Float64}, points::Matrix{Float64})

    edges = Matrix{Int64}(undef, size(nodes)[1], 2)
    for i = 1:(size(nodes)[1]-1)
        edges[i,:] =  [i, i+1]
    end
    edges[size(nodes)[1],:] = [size(nodes)[1], 1]

    #check for nodes in the edge

    tol = 1e-1

    stat = inpoly2(points, nodes, edges, atol =tol)

    # poly = Polygon(nodes...)
    
    return stat[:,1]
end