using LinearAlgebra
using AsapSections

"""
By Keith JL.
    makepixel(L::Real, t::Real, Lc::Real; n = 10)
L = length of pixel arm
t = thickness
Lc = straight region of pixel (length before arc)
n = number of discretizations for arc
"""
function make_pixel_section(L::Real, t::Real, Lc::Real; n = 10)

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

    return SolidSection(points)
end

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

rotate_2d_about_origin(point::AbstractVector{<:Real}, angle::Float64) = [cos(angle) -sin(angle); sin(angle) cos(angle)] * point

"""
By Keith JL.
L = length of pixel arm
t = thickness
Lc = straight region of pixel (length before arc)
n = number of discretizations for arc
"""
function make_Y_layup_section(L::Real, t::Real, Lc::Real; n = 10, offset = 0.)

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

    sections = SolidSection.([right_pixel, top_pixel, left_pixel])

    # return CompoundSection(sections)
    return sections
end

function make_X2_layup_section(L::Real, t::Real, Lc::Real; n = 10, offset = 0.)

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

    distance = top_pixel[2][1] - right_pixel[end][1] 

    right_pixel  = [[point[1] + distance, point[2]] for point in right_pixel]
    top_pixel    = [[point[1], point[2] + distance] for point in top_pixel]
    left_pixel   = [[point[1] - distance, point[2]] for point in left_pixel]  
    bottom_pixel = [[point[1], point[2] - distance] for point in bottom_pixel]

    sections = SolidSection.([top_pixel, bottom_pixel])
    # return CompoundSection(sections)
    return sections
end

function make_X4_layup_section(L::Real, t::Real, Lc::Real; n = 10, offset = 0.)

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

    distance = top_pixel[2][1] - right_pixel[end][1] 

    right_pixel  = [[point[1] + distance, point[2]] for point in right_pixel]
    top_pixel    = [[point[1], point[2] + distance] for point in top_pixel]
    left_pixel   = [[point[1] - distance, point[2]] for point in left_pixel]  
    bottom_pixel = [[point[1], point[2] - distance] for point in bottom_pixel]

    sections = SolidSection.([right_pixel, top_pixel, left_pixel, bottom_pixel])
    # return CompoundSection(sections)
    return sections
end