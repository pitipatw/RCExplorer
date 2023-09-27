using Makie, GLMakie


include("pixelgeo.jl")

L = 102.5
t = 17.5
Lc = 15.

nodes,~,~ = makepixel(L,t,Lc)
pts = Makie.Point2.(nodes)
f1 = Figure(resolution = (800,600))
ax1 = Axis(f1[1,1],aspect = DataAspect() )
n1 = scatter!(ax1, pts, color = :blue)


function make_pixel_geometry(L::Real, t::Real, Lc::Real; n = 100)

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


p2 = make_pixel_geometry(L,t,Lc)
pts2 = Makie.Point2.(p2)
scatter!(ax1, pts2, color = :red)

"""
By Keith JL.
    makepixel(L::Real, t::Real, Lc::Real; n = 10)
L = length of pixel arm
t = thickness
Lc = straight region of pixel (length before arc)
n = number of discretizations for arc
"""
function make_pixel_section(L::Real, t::Real, Lc::Real; n = 100)

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

    # return SolidSection(points)
    return points
end


s = make_pixel_section(L,t,Lc)
pts3 = Makie.Point2.(s)
scatter!(ax1, pts3, color = :green)
f1


rotate_2d_about_origin(point::AbstractVector{<:Real}, angle::Float64) = [cos(angle) -sin(angle); sin(angle) cos(angle)] * point
function make_Y_layup_section(L::Real, t::Real, Lc::Real; n = 100, offset = 0.)

    pixel = make_pixel_geometry(L, t, Lc; n = n)

    #offset from origin
    θ = pi / 6
    offset_vector = offset .* [cos(θ), -sin(θ)]

    #bottom right pixel
    right_pixel = [point + offset_vector for point in pixel]

    #top pixel
    top_pixel = rotate_2d_about_origin.(right_pixel, 2pi/3)

    #bottom left pixel
    left_pixel = rotate_2d_about_origin.(top_pixel, 2pi/3)

    # sections = SolidSection.([right_pixel, top_pixel, left_pixel])

    # return CompoundSection(sections)
    return [right_pixel, top_pixel, left_pixel]
end


full = make_Y_layup_section(L,t,Lc)
pts4 = Makie.Point2.(full[1])
pts5 = Makie.Point2.(full[2])
pts6 = Makie.Point2.(full[3])
scatter!(ax1, pts4, color = :yellow)
scatter!(ax1, pts5, color = :yellow)
scatter!(ax1, pts6, color = :yellow)
f1


move_2d(point::AbstractVector{<:Real}, vector::AbstractVector{<:Real}) = point .+ vector

function make_x2_layup_section(L::Real, t::Real, Lc::Real; n = 10, offset = 0.)

    pixel = make_pixel_geometry(L, t, Lc; n = n)

    #offset from origin
    θ = pi / 6
    offset_vector = offset .* [cos(θ), -sin(θ)]

    #base pixel
    base_pixel = [point + offset_vector for point in pixel]

    #right pixel 
    right_pixel = rotate_2d_about_origin.(base_pixel, pi/6)
    
    #top pixel
    top_pixel = rotate_2d_about_origin.(right_pixel, pi/2)

    #left pixel
    left_pixel = rotate_2d_about_origin.(top_pixel, pi/2)

    #bottom pixel
    bottom_pixel = rotate_2d_about_origin.(left_pixel, pi/2 )

    # sections = SolidSection.([right_pixel, top_pixel, left_pixel])
    spread = top_pixel[2][1] - right_pixel[end][1] 

    right_pixel  = [[point[1] + spread, point[2]] for point in right_pixel]
    top_pixel    = [[point[1], point[2] + spread] for point in top_pixel]
    left_pixel   = [[point[1] - spread, point[2]] for point in left_pixel]  
    bottom_pixel = [[point[1], point[2] - spread] for point in bottom_pixel]
    # return CompoundSection(sections)
    return [top_pixel, bottom_pixel]
end

function make_x4_layup_section(L::Real, t::Real, Lc::Real; n = 10, offset = 0.)

    pixel = make_pixel_geometry(L, t, Lc; n = n)

    #offset from origin
    θ = pi / 6
    offset_vector = offset .* [cos(θ), -sin(θ)]

    #base pixel
    base_pixel = [point + offset_vector for point in pixel]

    #right pixel 
    right_pixel = rotate_2d_about_origin.(base_pixel, pi/6)
    
    #top pixel
    top_pixel = rotate_2d_about_origin.(right_pixel, pi/2)

    #left pixel
    left_pixel = rotate_2d_about_origin.(top_pixel, pi/2)

    #bottom pixel
    bottom_pixel = rotate_2d_about_origin.(left_pixel, pi/2 )

    # sections = SolidSection.([right_pixel, top_pixel, left_pixel])
    spread = top_pixel[2][1] - right_pixel[end][1] 

    right_pixel  = [[point[1] + spread, point[2]] for point in right_pixel]
    top_pixel    = [[point[1], point[2] + spread] for point in top_pixel]
    left_pixel   = [[point[1] - spread, point[2]] for point in left_pixel]  
    bottom_pixel = [[point[1], point[2] - spread] for point in bottom_pixel]
    # return CompoundSection(sections)
    return [right_pixel, top_pixel, left_pixel, bottom_pixel]
end




n1 = make_x2_layup_section(L,t,Lc)
n2 = make_x4_layup_section(L,t,Lc)

f1 = Figure(resolution = (800, 800))
ax1 = Axis(f1[1,1], aspect = DataAspect(), limits = (-110, 110, -110, 110))
ax2 = Axis(f1[1,2], aspect = DataAspect(), limits = (-110, 110, -110, 110))

p11 = Makie.Point2.(n1[1])
p12 = Makie.Point2.(n1[2])

p21 = Makie.Point2.(n2[1])
p22 = Makie.Point2.(n2[2])
p23 = Makie.Point2.(n2[3])
p24 = Makie.Point2.(n2[4])

scatter!(ax1, p11, color = :blue)
scatter!(ax1, p12, color =:blue)

scatter!(ax2, p21, color = :blue)
scatter!(ax2, p22, color =:blue)
scatter!(ax2, p23, color = :blue)
scatter!(ax2, p24, color =:blue)

f1




f1

scatter!(ax1, pts7, color = :red)
scatter!(ax1, pts8, color = :red)
scatter!(ax1, pts9, color = :red)
scatter!(ax1, pts10, color = :red)
f1