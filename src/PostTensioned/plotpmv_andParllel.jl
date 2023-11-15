using Makie, GLMakie
using DataFrames
using PlotlyJS

date = Dates.today()
time = Dates.now()
CSV.write("results//output_$date.csv", DataFrame(results, :auto))
file = "results//output_$date.csv"
cin = Matrix(CSV.read(file, DataFrame))

function plotterrain(cin::Matrix{Float64})
    f1 = Figure(resolution=(1200, 300))

    title1 = "Mu [kNm]"
    title2 = "Pu [kN]"
    title3 = "Vu [kN]"
    ax1 = Axis3(f1[1, 1], xlabel="fc′", ylabel="as", zlabel=title1, title=title1)
    ax2 = Axis3(f1[1, 2], xlabel="fc′", ylabel="as", zlabel=title2, title=title2)
    ax3 = Axis3(f1[1, 3], xlabel="fc′", ylabel="as", zlabel=title3, title=title3)

    ax2.aspect = (1, 1, 2)
    ax3.aspect = (1, 1, 2)
    fc′ = cin[:, 1]
    as = cin[:, 2]
    mu = cin[:, 6]
    pu = cin[:, 5]
    vu = cin[:, 7]
    ec = cin[:, 3] ./ maximum(cin[:, 3])
    fpe = cin[:, 4] ./ maximum(cin[:, 4]) * 10

    scatter!(ax1, fc′, as, mu, transparency=true, color=ec, markersize=fpe)
    scatter!(ax2, fc′, as, pu, transparency=true, color=ec, markersize=fpe)
    scatter!(ax3, fc′, as, vu, transparency=true, color=ec, markersize=fpe)


    return f1
end

f1 = plotterrain(cin)


df = DataFrame(cin, :auto)

labels = ["fc′", "as", "ec", "fpe", "pu", "mu", "vu", "embodied"]
mytrace = parcoords(; line=attr(color=df.x6), dimensions=[attr(label=labels[i], values=df[!, i]) for i in 1:8])

layout = Layout(title_text="Parallel Coordinates Plot", title_x=0.5, title_y=0
)
myplot = PlotlyJS.plot(mytrace, layout)
open("./parplot$date.html", "w") do io
    PlotlyBase.to_html(io, myplot.plot)
end