module Catalog
#design catalog
include("Definitions.jl")
include("Rebars.jl")
include("Capacities.jl")
function circle_pts(r::Float64; n = 50, base = [0. , 0.])
    return [r .* [cos(thet), sin(thet)] .+ base for thet in range(0, 2pi, n)]
end



function main()

widths = 100.:20.:500.
heights = 100.:20.:500.
rebars = bar_combination_and_area #get from Hazel's work
fy = 200_000
dc = 50 # Covering [mm]

catalogs = Dict()
count = 0 
for w in widths
    for h in heights
        #rectangular section
    
        # p1.....p2
        # .      .
        # .      .
        # .      .
        # p4.....p3
    
        p1 = [0. , 0.],
        p2 = [w , 0.],
        p3 = [w, -h],
        p4 = [0., -h]
        pts = [p1,p2,p3,p4]
        section = SolidSection(pts)

        #steel is Hazel's steel comp
        for (r, area) in rebars
            nr = 1 #find the number of rebars sum of number between []
            rebar = RebarSection(rebars[r], repeat([fy], nr),repeat([0], nr),repeat([-h+dc], nr),repeat([1.99], nr))
            #check if this r fits in the given width.
            spacing_check = true
            as_min = find_A_smin(c)
            as_min_check = sum(rebar.ast) < as_min

            if !spacing_check || !as_min_check 
                continue
            else
            count = count+1 
            #create a concrete section 
            #start with section geometry using all_A_s_combo_bigger_than_input_A_s_list
            geometry = 0 #something by ASAP 
            #concrete section c 

            c = 0 #ConcreteSection
            #Calculate the capacity.
            P = find_Pn(c)
            M = find_Mu(c)
            # V = find_Vn(c)
            push!(count , [c,P,M,V])
            end
        end
    end
end


# after got all of the catalog, compared them 
println("Done catalog")
return catalogs
end

end

# catalog = Catalog.main()

#now, we need section from karamba. 

