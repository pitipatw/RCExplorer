# module Catalog
#design catalog
using DataFrames
include("Definitions.jl")
include("Rebars/Rebars.jl")
include("RcCapacities.jl")

println("Need to do ρmax")

function find_ρ_min(fc′::Real, f_y::Float64)
    return 3 * sqrt(fc′) / f_y
end

"""
find Maximum area of steel (As max)
based on minimum allowable strain (> 0.002)
"""
function find_ρ_max()


function design_space()
    set_fc′ = 25.0:0.5:55.0
    set_d   = 100.0:25:500.0
    set_bd_ratio = 0.5:0.05:1.0
    # widths = 200.:100.:500.
    # heights = 200.:100.:500.
    # set_bd_ratio = 0.5:0.05:1 #b/d ratio b = bd_ratio*d
    # rebars = bar_combinations  #get from Hazel's work
    # rebars = bar_combinations  #get from Hazel's work
    return set_fc′, set_d, set_bd_ratio
end

function get_catalog(bar_combinations)
    set_fc′, set_d, set_bd_ratio = design_space()

    #some constants
    fy = 420.0
    covering = 40. #ACI318M-19 Table 20.5.1.3.1, Not exposed to weather or in contact with ground

    
    #results placeholder
    Cs = Vector{ConcreteSection}()
    Ps = Vector{Float64}()
    Ms = Vector{Float64}()
    GWPs = Vector{Float64}()
    Section_IDs = Vector{Int64}()
    #catalog placeholder
    catalog = Dict()

    #for different combination of sections and IDs.
    section_ID = 0
    count = 0 
    
    for bd_ratio in set_bd_ratio
        for h in heights
            section_ID = section_ID + 1
            b = bd_ratio*d
            #rectangular section
            # p1.....p2
            # .      .
            # .      .
            # .      .
            # p4.....p3
        
            p1 = [0. , 0.]
            p2 = [w , 0.]
            p3 = [w, -h]
            p4 = [0., -h]
            pts = [p1,p2,p3,p4]
            section = SolidSection(pts)
            for fc′ in fc′s



                #Rebars will be single layer, 50mm up from the bottom
                #y = -h + 50 [mm]
                for (k,r_idx) in map
                    # println(typeof(r_idx))
                    # println(bar_combinations)
                    areas = bar_combinations[r_idx]
                    ds = parse.(Float64,split(map[k],"_")) #vector of diameters
                    #spacing check
                    nr = length(ds) #number of rebars
                    spacing = maximum([40, 1.5*maximum(ds)])
                    spacing_check = w > ( 2*covering + sum(ds) + (nr-1)*spacing )
                    
                    #minimum rebar check
                    as_min = find_A_smin(fc′, w, h-covering, fy)
                    as_min_check = sum(areas) < as_min

                    if !spacing_check || !as_min_check 
                        # println("FAIL")
                        continue
                    else
                        # create rebar section
                        count = count +1 

                        #x position is a bit tricky.
                        # goes from left to right.
                        if length(ds) == 1 #put in the middle of we
                            xs = [w/2]
                        elseif length(ds) == 2
                            offset = covering + ds[1]/2
                            xs = [offset, w-offset]
                        elseif length(ds) == 3 
                            offset = covering + ds[1]/2
                            xs = [offset, w/2, w-offset]

                        else
                        #in case there are more, 
                            xs = [covering + ds[1]/2]
                            for ii = 2:(nr-1)
                                push!(xs,xs[end]+spacing+ds[ii]/2)
                            end
                            push!(xs, w - covering - ds[end]/2)
                        end

                            
                        # xs = repeat([0.0], nr)
                        ys = -h + covering .+ ds./2
                        fys = repeat([fy], nr)
                        rebars = RebarSection(areas, fys, xs, ys, ds)

                        #Create a concrete section here.
                        c = ConcreteSection(fc′, section, rebars)
                        #Calculate the capacity.
                        P = find_Pu(c)
                        M = find_Mu(c)
                        # V = find_Vn(c)
                        push!(Cs,c)
                        push!(Ps,P)
                        push!(Ms,M)
                        push!(GWPs, c.gwp)
                        push!(Section_IDs, section_ID)
                    end
                end
            end
        end
    end


    # after got all of the catalog, compared them 
    catalog = DataFrame(id = 1:count, Section = Cs, Pu=Ps, Mu= Ms, Gwp = GWPs, Section_ID = Section_IDs)
    println("Done catalog")
    return catalog
end

# end
catalog = get_catalog(bar_combinations);
# catalog = Catalog.main()

#now, we need section from karamba. 

