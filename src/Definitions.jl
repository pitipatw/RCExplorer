#Defines structs
using ASAPsection
#do I always need 
mutable struct RebarSection
    ast::Vector{Float64}
    # asc::Vector{Float64} #compression steel
    fy::Vector{Float64}
    x::Vector{Float64} #relative to the centroid of the section
    y::Vector{Float64}
    d::Vector{Float64}
    gwp::Vector{Float64} #probably constant
end

function fc′_to_gwp(fc′)
    #load the function, maybe precalc into an equation and put it in here
    # (dummy) gwp = 0.001 * fc′ + 0.002 *fc′^2
    gwp = 0.14 #placeholder.
    return gwp
end

@kwdef mutable struct ConcreteSection
    fc′::Float64
    E::Float64 = 4700*sqrt(fc′)
    gwp::Float64 = fc′_to_gwp(fc′) #could be a function of fc′ (from CLF)
    geometry::PolygonalSection
    rebars::RebarSection
    # ec::Float64 = gwp*(geometry.area - rebar.totalarea) + rebar.totalarea.rebar.gwp
    #still in decision to embed them inside ConcreteSection or not.
    # P::Float64 = 0.0
    # M::Float64 = 0.0
    # V::Float64 = 0.0
end

