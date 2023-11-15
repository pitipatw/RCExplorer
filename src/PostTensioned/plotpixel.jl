using Makie, GLMakie
using AsapSections

include("pixelgeo.jl")


function plotpixel(L::Float64, t::Float64, Lc::Float64)

    # L = 300.0
    # t = 30.0
    # Lc = 30.0

    section1 = make_Y_layup_section(L, t, Lc)
    section2 = make_X2_layup_section(L, t, Lc)
    section3 = make_X4_layup_section(L, t, Lc)

    f1 = Figure(resolution=(800, 800))
    ax1 = Axis(f1[1, 1], xlabel="x", ylabel="y", aspect=DataAspect(), limits=(-1, 1, -1, 1) .* 1.05 .* L)
    ax2 = Axis(f1[1, 2], xlabel="x", ylabel="y", aspect=DataAspect(), limits=(-1, 1, -1, 1) .* 1.05 .* L)
    ax3 = Axis(f1[2, 1], xlabel="x", ylabel="y", aspect=DataAspect(), limits=(-1, 1, -1, 1) .* 1.05 .* L)


    plotsection(ax, section) = [scatter!(ax, section[i].points) for i in eachindex(section)]
    plotsection(ax1, section1)
    plotsection(ax2, section2)
    plotsection(ax3, section3)

    return f1

end

# plotpixel(200., 30.,10.)

# function mappixel
y, A = depth_map(compoundsection1, 250)

# end


compoundsection1 = CompoundSection(section1)
compoundsection2 = CompoundSection(section2)
compoundsection3 = CompoundSection(section3)

compoundsection1.area
compoundsection2.area
compoundsection3.area

Arequired = 20000.0
d_at_A = depth_from_area(compoundsection1, Arequired)

A_at_d = area_from_depth(section1, d)

# clipped_vertices = sutherland_hodge(section::PolygonalSection, y::Float64)
# clipped_section = sutherland_hodge(section::PolygonalSection, y::Float64; return_section = true)

# clipped_section = AsapSections.sutherland_hodgman(compoundsection1, d_at_A; return_section = true)

# clipped_vertices = sutherland_hodge(compoundsection1, d_at_A)
