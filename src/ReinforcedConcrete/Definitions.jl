#Defines structs
using AsapSections
#do I always need 
mutable struct RebarSection
    ast::Vector{Float64}
    # asc::Vector{Float64} #compression steel
    fy::Vector{Float64}
    x::Vector{Float64} #relative to the centroid of the section
    y::Vector{Float64}
    d::Vector{Float64} #diameter
    gwp::Vector{Float64} ##= 1.99 #probably constant
end

function RebarSection(areas, fy, xs, ys, ds)
    return RebarSection(areas, fy, xs,ys,ds,repeat([1.99], length(areas)))
end

function fc′_to_eec(fc′)
    #load the function, maybe precalc into an equation and put it in here
    # (dummy) gwp = 0.001 * fc′ + 0.002 *fc′^2
    # gwp = 0.0012*fc′+0.07
    gwp = (-0.0627*fc′^2 + 10.009*fc′ + 84.148)/2400

    return gwp
end

mutable struct ConcreteSection
    fc′::Float64
    E::Float64 ##= 4700*sqrt(fc′)
    gwp::Float64 ##= fc′_to_gwp(fc′) #could be a function of fc′ (from CLF)
    geometry::AsapSections.PolygonalSection
    rebars::RebarSection
    # ec::Float64 = gwp*(geometry.area - rebar.totalarea) + rebar.totalarea.rebar.gwp
    #still in decision to embed them inside ConcreteSection or not.
    # P::Float64 = 0.0
    # M::Float64 = 0.0
    # V::Float64 = 0.0
end


#function for defining ConcreteSection
function ConcreteSection(fc′::Float64, section::AsapSections.PolygonalSection, rebars::RebarSection)
    section_gwp = fc′_to_eec(fc′)*(section.area - sum(rebars.ast)) + sum(rebars.ast .* rebars.gwp)     
    section_gwp = section_gwp/1e6*2400
    return ConcreteSection(fc′,
                           4700*sqrt(fc′),
                           section_gwp,
                           section,
                           rebars
                           )
end