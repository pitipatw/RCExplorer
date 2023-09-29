using Makie, GLMakie
using PlotlyJS

function VizCatalog(catalog)
    figure1 = Figure(resolution = (1920, 720))

    # gwp vs fc' (best)
    ax1 = Axis(figure1[1,1],
        xlabel = "fc′ [MPa]", ylabel = "GWP kgCO2e/kg")
    fc′s = getfield.(catalog[!,:Section], :fc′)
    s1 = scatter!(ax1, fc′s, catalog[!, :Gwp], color = catalog[!, :Mu])


    ax2 = Axis(figure1[1,2],
    xlabel = "Mu [Nm]", ylabel = "GWP [kgCO2e/kg]")
    fc′s = getfield.(catalog[!,:Section], :fc′)
    s2 = scatter!(ax2, catalog[!, :Mu]/1000, catalog[!, :Gwp], color = fc′s )

    Colorbar(figure1[1,3], s2, label = "fc′", labelrotation =0)

    return figure1
end
f1 = VizCatalog(catalog)
# save("gwpperfc.png", VizCatalog(catalog))

function VizCatalog_by_section(catalog)
    figure1 = Figure(resolution = (1920,1000))
    Section_IDs = unique(catalog[!,:Section_ID])
    ns = length(Section_IDs)
    ax1 = Axis(figure1[1,1],
        xlabel = "Mu [kNm]", ylabel = "GWP kgCO2e/kg")

    ax2 = Axis(figure1[1,2],
    xlabel = "Mu [kNm]", ylabel = "GWP kgCO2e/kg")
    fc′s = getfield.(catalog[!,:Section], :fc′)
    s1 = scatter!(ax1, catalog[!, :Mu]/1e6, catalog[!, :Gwp], color = fc′s)
    s2 = scatter!(ax2, catalog[!, :Mu]/1e6, catalog[!, :Gwp], color = catalog[!, :Section_ID],
    colormap = cgrad(:Spectral,ns, categorical = true), opacity =  fc′s./maximum(fc′s))
    Colorbar(figure1[2,1], s1, label = "fc′", vertical = false)
    Colorbar(figure1[2,2], s2, label = "Section", vertical = false)

    Label(figure1[1, 1:2, Top()], "Rc Beam Catalog", valign = :bottom,
    font = :bold, fontsize = 30,
    padding = (0, 0, 5, 0))
    # # #loop each section ID and plot it's lines
    # Section_IDs = unique(catalog[!,:Section_ID])
    # for i in eachindex(Section_IDs)
    #     section_ID = Section_IDs[i]
    #     selected = filter(:Section_ID => ==(section_ID), sort(catalog, [:Gwp, :Mu]))

    #     lines!(ax2, selected[:,:Mu]/1e6, selected[:, :Gwp])
    # # Colorbar(figure1[1,3], s2, label = "fc′", labelrotation =0)
    # end
    return figure1
end

f2 = VizCatalog_by_section(catalog)
# save("bySection.png", f2)

function VizCatalog_by_mu(catalog)
    figure1 = Figure(resolution = (1920,1000))

    #use menu to select mu range. 
    #a slider bar to select mu range, and show that on the plot




    Section_IDs = unique(catalog[!,:Section_ID])
    ns = length(Section_IDs)
    ax1 = Axis(figure1[1,1],
        xlabel = "Mu [kNm]", ylabel = "GWP kgCO2e/kg")

    ax2 = Axis(figure1[1,2],
    xlabel = "Mu [kNm]", ylabel = "GWP kgCO2e/kg")
    fc′s = getfield.(catalog[!,:Section], :fc′)
    s1 = scatter!(ax1, catalog[!, :Mu]/1e6, catalog[!, :Gwp], color = fc′s)
    s2 = scatter!(ax2, catalog[!, :Mu]/1e6, catalog[!, :Gwp], color = catalog[!, :Section_ID],
    colormap = cgrad(:Spectral,ns, categorical = true))
    Colorbar(figure1[2,1], s1, label = "fc′", vertical = false)
    Colorbar(figure1[2,2], s2, label = "Section", vertical = false)

    Label(figure1[1, 1:2, Top()], "Rc Beam Catalog", valign = :bottom,
    font = :bold, fontsize = 30,
    padding = (0, 0, 5, 0))
    # # #loop each section ID and plot it's lines
    # Section_IDs = unique(catalog[!,:Section_ID])
    # for i in eachindex(Section_IDs)
    #     section_ID = Section_IDs[i]
    #     selected = filter(:Section_ID => ==(section_ID), sort(catalog, [:Gwp, :Mu]))

    #     lines!(ax2, selected[:,:Mu]/1e6, selected[:, :Gwp])
    # # Colorbar(figure1[1,3], s2, label = "fc′", labelrotation =0)
    # end
    return figure1
end





function ParplotCatalog(df) 
    fc′s = getfield.(catalog[!,:Section], :fc′)
    mytrace = parcoords(;line = attr(color=df.Gwp)
                 ,dimensions = [ attr(
                    label = "fc′",
                    values = fc′s,
                 ),
                            attr(
                                label = "Concrete gross area",
                                values = getfield.(getfield.(catalog[!,:Section], :geometry),:area)
                                ),
                            # attr(label = "Section Depth",
                            #     values = 
                            #     ),
                            attr(label = "GWP",
                                 values = df.Gwp
                                ),
                            attr(label = "Mu",
                            values = df.Mu
                            ),
                            attr(label = "Pu",
                            values = df.Pu),
                            # attr(label = "Steel Area",
                            # values = )
                   ]);

    layout = Layout(title_text="Parallel Coordinates Plot"
                  , title_x=0.5 
                  , title_y=0
                   )

    myplot = PlotlyJS.plot(mytrace,layout)

    return myplot
end


# open("./parallel.html", "w") do io
#     PlotlyBase.to_html(io, ParplotCatalog(catalog).plot)
# end