#Defines structs


mutable struct RebarSection
    A::Vector{Float64}
    x::Vector{Float64} #relative to the centroid of the section
    y::Vector{Float64}
    d::Vector{Float64}
end

@kwdef mutable struct ConcreteSection
    fc′ ::Float64
    A::Float64
    Rebars::RebarSection
    E::Float64 = 4700sqrt(fc′)
end

function ConcreteSection(fc′::Float64, A::Float64, Rebars::RebarSection)
    E = 4700*sqrt(fc′)
    ConcreteSection(fc′::Float64, A::Float64, Rebars::RebarSection, E::Float64)
end
r = RebarSection([1.],[2.],[3.],[4.])
c = ConcreteSection(10.,20.,r)

c.E