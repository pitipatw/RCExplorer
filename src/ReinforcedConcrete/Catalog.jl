# module Catalog
#design catalog
using DataFrames
include("Definitions.jl")
include("Rebars/Rebars.jl")
include("RcCapacities.jl")

"""
β1 from ACI 318-19
"""
function get_β1(fc′::Real)
    return clamp(0.85 - 0.05 * (fc′ - 28) / 7, 0.65, 0.85)
end


"""
find the boundary (ρ_min, ρ_max) of the reinforcement ratio

Input\\
fc′: concrete compressive strength [MPa]\\
Input [Optional]\\
fy = 420 steel yield strength [MPa]\

Outputs\\
ρ_min: minimum reinforcement ratio\\
ρ_max: maximum reinforcement ratio\\
"""
function get_ρ_bounds(fc′::Real; 
    fy::Float64 = 420.0)
    β1 = get_β1(fc′)

    ρ_min1 =  0.25 * sqrt(fc′) / fy
    ρ_min2 =  1.4/fy
    ρ_min = maximum([ρ_min1, ρ_min2])

    ρ_max = 3/5*0.85*β1*fc′/fy

    return ρ_min, ρ_max
end

"""
Generate the design space
Output as a dictionary might be better in term of performance.
"""
function get_design_space()
    set_fc′ = 25.0:0.5:55.0
    set_d   = 100.0:25:500.0
    set_bd_ratio = 0.5:0.05:1.0
    set_mu = 1e6:5e6:1500e6
    # widths = 200.:100.:500.
    # heights = 200.:100.:500.
    # set_bd_ratio = 0.5:0.05:1 #b/d ratio b = bd_ratio*d
    # rebars = bar_combinations  #get from Hazel's work
    # rebars = bar_combinations  #get from Hazel's work
    

    # design_space = Dict()
    # for i1 in set_fc′
    #     for i2 in set_d
    #         for i3 in set_bd_ratio
    #             push!(design_space, (i1,i2,i3))
    #         end
    println("Design Space of ", prod(length.([set_fc′, set_d, set_bd_ratio])) , " points")
    return set_fc′, set_d, set_bd_ratio, set_mu
end

function get_catalog()
    #some constants
    fy = 420.0
    covering = 40. #ACI318M-19 Table 20.5.1.3.1, Not exposed to weather or in contact with ground
     
    set_fc′, set_d, set_bd_ratio, set_mu = get_design_space()
    #results placeholder
    Cs = Vector{ConcreteSection}()
    Ps = Vector{Float64}() #Compressive Capacity
    Ms = Vector{Float64}() #Moment Capacity
    fc′s = Vector{Float64}()
    Areas = Vector{Float64}()
    ρs = Vector{Float64}()
    GWPs = Vector{Float64}()
    Section_IDs = Vector{Int64}()

    #for different combination of sections and IDs.
    section_ID = 0
    count = 0 
    
    for bd_ratio in set_bd_ratio
        for d in set_d
            
            b = bd_ratio*d

            #reate an AsapSection section
            #rectangular section
            # p1.....p2
            # .      .
            # .      .
            # .      .
            # p4.....p3
            
            #for now w = b , d = h, normally w = b + 2*cover
            w = b
            h = d
            p1 = [0. , 0.]
            p2 = [w , 0.]
            p3 = [w, -h]
            p4 = [0., -h]
            pts = [p1,p2,p3,p4]
            section = SolidSection(pts)

            for fc′ in set_fc′
                section_ID = section_ID + 1
            # for mu in set_mu
                #get the bounds of ρ
                ρ_min , ρ_max = get_ρ_bounds(fc′)
                n_ρ = 100
                ρ_step = (ρ_max - ρ_min)/(n_ρ-1)
            
                #now, we will sample a 100 samples over the range of ρ
                for ρ in ρ_min:ρ_step:ρ_max
                    #calculate the As
                    as = ρ*b*d
                    #rectangular rebar (dummy)
                    rebars = RebarSection([as], [fy], [b/2], [-h + as/b], [0.])

                     
                    #Create a concrete section here.
                    # @show fc′ = find_fc′(mu, section, rebars)

                    c = ConcreteSection(fc′, section, rebars)
                    #Calculate the capacity.
                    P = find_Pu(c)
                    M = find_Mu(c)
                    if M < 0
                        continue
                    end
                    count = count +1
                    # V = find_Vn(c)
                    push!(Cs,c)
                    push!(Ps,P)
                    push!(Ms,M)
                    push!(GWPs, c.gwp)
                    push!(Section_IDs, section_ID)

                    #will get rid of this later
                    push!(fc′s, fc′)
                    push!(Areas, c.geometry.area)
                    push!(ρs, ρ)
                end
            end
        end
    end

    # after got all of the catalog, compared them 
    catalog = DataFrame(id = 1:count, Section = Cs,fc′ = fc′s, Area = Areas, ρ = ρs, Pu=Ps, Mu= Ms, Gwp = GWPs, Section_ID = Section_IDs)
    println("Done catalog with ", count, " points")
    return catalog
end

# end
catalog = get_catalog();
# catalog = Catalog.main()

#now, we need section from karamba. 

