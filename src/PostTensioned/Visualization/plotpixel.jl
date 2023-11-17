using Makie, GLMakie, CairoMakie
include("../Geometry/pixelgeo.jl")


function plotpixel(L::Float64, t::Float64, Lc::Float64)

    # L = 300.0
    # t = 30.0
    # Lc = 30.0

    compound1 = make_Y_layup_section(L, t, Lc)
    compound2 = make_X2_layup_section(L, t, Lc)
    compound3 = make_X4_layup_section(L, t, Lc)

    f1 = Figure(resolution=(800, 800))
    ax1 = Axis(f1[1, 1], title = "Y layup", xlabel="x", ylabel="y", aspect=DataAspect(), limits=(-1, 1, -1, 0.75) .* 1.05 .* L)
    ax2 = Axis(f1[1, 2], title = "X2 layup", xlabel="x", ylabel="y", aspect=DataAspect(), limits=(-1, 1, -1, 1) .* 1.05 .* L)
    ax3 = Axis(f1[2, 1], title = "X4 layup", xlabel="x", ylabel="y", aspect=DataAspect(), limits=(-1, 1, -1, 1) .* 1.05 .* L)

    ax4 = Axis(f1[2,2,], limits = (-50,50,0,20), )
    hidedecorations!(ax4)  # hides ticks, grid and lables
    hidespines!(ax4)  # hide the frame
    text!(
        ax4, 0, 10,
        text = "L: $L \n t: $t \n Lc: $Lc",
        font = :bold,
        align = (:center, :center),
        # offset = (4, -2),
        # space = :relative,
        fontsize = 24,
        justification = :left)
    # text!(ax4,
    # [0 0;0 -10; 0 -20])
    #Define a quick plot function

    plotsection(ax::Axis, compound::CompoundSection) = [lines!(ax, hcat(compound.solids[i].points, compound.solids[i].points[:,1]), markersize = 7.5) for i in eachindex(compound.solids)]
    plotsection(ax1, compound1)
    plotsection(ax2, compound2)
    plotsection(ax3, compound3)

    return f1

end

L = 300.0
t = 50.0
Lc = 15.0
plotpixel(L,t,Lc)

# # function mappixel
# y, A = depth_map(compoundsection1, 250)

# # end


# compoundsection1 = CompoundSection(compound1)
# compoundsection2 = CompoundSection(compound2)
# compoundsection3 = CompoundSection(compound3)

# compoundsection1.area
# compoundsection2.area
# compoundsection3.area

# Arequired = 20000.0
# d_at_A = depth_from_area(compoundsection1, Arequired)

# A_at_d = area_from_depth(compound1, d)

# # clipped_vertices = sutherland_hodge(section::PolygonalSection, y::Float64)
# # clipped_section = sutherland_hodge(section::PolygonalSection, y::Float64; return_section = true)

# # clipped_section = AsapSections.sutherland_hodgman(compoundsection1, d_at_A; return_section = true)

# # clipped_vertices = sutherland_hodge(compoundsection1, d_at_A)
