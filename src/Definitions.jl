#Defines structs


mutable struct RebarSection
    ast::Vector{Float64}
    # asc::Vector{Float64} #compression steel
    fy::Vector{Float64}
    x::Vector{Float64} #relative to the centroid of the section
    y::Vector{Float64}
    d::Vector{Float64}
    gwp::Vector{Float64} #probably constant
end

@kwdef mutable struct ConcreteSection
    fc′ ::Float64
    ag::Float64
    rebars::RebarSection
    E::Float64 = 4700sqrt(fc′)
    gwp::Float64 #could be a function of fc′ (from CLF)

    a::Float64
    c::Float64
end

function fc′_to_gwp(fc′)
    #load the function, maybe precalc into an equation and put it in here
    # (dummy) gwp = 0.001 * fc′ + 0.002 *fc′^2
    gwp = 0.14 #placeholder.
    return gwp
end

function ConcreteSection(fc′::Float64, A::Float64, Rebars::RebarSection)
    E = 4700*sqrt(fc′)
    gwp = fc′_to_gwp(fc′)
    println("Warning, a and c still 0")
    ConcreteSection(fc′::Float64, A::Float64, Rebars::RebarSection, E::Float64, gwp::Float64, 0.0,0.0)
end
r = RebarSection([1.],[2.],[3.],[4.],[1.5],[1.5])
c = ConcreteSection(10.,20.,r)

c.E