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
    xlabel = "Mu [N]", ylabel = "GWP [kgCO2e/kg]")
    fc′s = getfield.(catalog[!,:Section], :fc′)
    s2 = scatter!(ax2, catalog[!, :Mu]/1000, catalog[!, :Gwp], color = fc′s )

    Colorbar(figure1[1,3], s2, label = "fc′", labelrotation =0)
    



    return figure1
end

save("gwpperfc.png", VizCatalog(catalog))


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

ParplotCatalog(catalog)