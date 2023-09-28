using Makie, GLMakie

function VizCatalog(catalog)
    figure1 = Figure(resolution = (1920, 720))

    # gwp vs fc' (best)
    ax1 = Axis(figure1[1,1])
    fc′s = getfield.(catalog[!,:Section], :fc′)
    scatter!(ax1, fc′s, catalog[!, :Gwp], color = catalog[!, :Mu])



    return figure1
end

VizCatalog(catalog)