"""
Post processing the choices.
"""
# function postprocess(outvod, data)

#preparing the data
#check all of the elements
elements_all = Vector{Int64}(undef, size(data,1))
elements_to_sections = Dict{Int64, Vector{Int64}}()
decisions = Vector{Int64}(undef, size(data,1))
for i in eachindex(data)
    elements_all[i] = parse(Float64,data[i]["e_idx"])
    if haskey(elements_to_sections, elements_all[i])
        elements_to_sections[elements_all[i]] = vcat(elements_to_sections[elements_all[i]], i)
    else
        elements_to_sections[elements_all[i]] = [i]
    end
end

elements = collect(keys(elements_to_sections))

#loop each element
for i in eachindex(elements)
    element_idx = elements[i] #element index (in case elements is not in order)
    sections = elements_to_sections[element_idx] # all section indices that associate with the element
    println("Element :$element_idx")
    println("   Sections: $sections")
    # number of sections in that element
    ns = size(sections,1)

    #section should be in consecutive order.
    ns_min = minimum(sections) 
    ns_max = maximum(sections)
    @show ns_min,ns_max, ns
    @assert ns_max - ns_min + 1 == ns

    #start at mid span of the section
    if mod(ns,2) == 0 
        mid_section_idx =  ns/2 + ns_min -1
    else
        mid_section_idx = (ns+1)/2 + ns_min -1
    end
    mid_section_idx = Int(mid_section_idx)

    #choices for mid section
    mid_section_choices = DataFrame(outvod[mid_section_idx])
    println("There are $(size(mid_section_choices,1)) choices for mid section $mid_section_idx")
    #get order label
    mid_section_choices[!,"order"] = 1:size(mid_section_choices,1)
    #will loop based on this order
    mid_section_choices_sorted = sort(mid_section_choices , ["embodied", "fpe", "as", "fc","ec"])
    
    pick_idx_mid = 1
    pick_idx = 1 

    current_section_idx = ns_min
    element_decisions = Bool.(zeros(ns,1))
    # element_selections = Vector{Int64}(undef, ns)
    counter = 0
    while !prod(element_decisions) && counter < 10000
        counter += 1
        println("Mid idx: $mid_section_idx")
        println("Current section index: $current_section_idx")
        if current_section_idx > ns_max #loop entire section of this element, but still doesnt find all decisions
            #reset with pick_idx_mid +=1 
            pick_idx_mid +=1
            current_section_idx = ns_min
            
        elseif pick_idx_mid > size(mid_section_choices,1)
                println("Unresolved sections for elements $element_idx")
                break
    
        elseif current_section_idx != mid_section_idx #skip mid section
            pick_mid_choice = mid_section_choices_sorted[pick_idx_mid,:]
            pick_mid_fc = pick_mid_choice["fc"]
            pick_mid_as = pick_mid_choice["as"]
            pick_mid_fpe = pick_mid_choice["fpe"]
            pick_idx_mid_abs = pick_mid_choice["order"]

            #find as and fpe in the current section 
            current_section_choices = DataFrame(outvod[current_section_idx])

            #only get the choices that has as and fpe
            feasible_choices = current_section_choices[(current_section_choices[:,"as"] .== pick_mid_as) .& (current_section_choices[:,"fpe"] .== pick_mid_fpe),:]

            if size(feasible_choices,1) == 0 
                println("Cant find for section: $current_section_idx, move on to the next section")
                #if no choices, then move on to the next choices for the mid section
                #and start all over again.
                current_section_idx = ns_min
                pick_idx_mid +=1
                continue
            else
                #if there are available choices 
                @show decisions[current_section_idx] = pick_idx
                # element_selections[current_section_idx - ns_min + 1] = pick_idx
                @show element_decisions[current_section_idx - ns_min + 1] = true
                #move on to the next section in this element
                current_section_idx += 1
                pick_idx = 1 #reset for this index
            end
        else
            #current section is mid section
            current_section_idx += 1
        end
    end

end

# return decisions
# end



        #get choices for the current section
        global current_section_choices = DatFrame(outvod[current_section_idx])
        section_choices[!,"order"] = 1:size(section_choices,1)

        section_choices_sorted = sort(section_choices , ["embodied", "fpe"])
        abs_idx = sorted_choices[pick_idx,"order"] 
        pick_idx = 1 
    
        while pick_idx <= length(section_choices)


            

            pick_idx += 1


            #see if as and fpe works for the others. 
            #if not, then move on to the next pick
            #if yes, then keep it




    #now, we go through other section.

    idx += 1 

    while idx <= ns_max
        choices = DatFrame(outvod[idx])
        choices[!,"order"] = 1:size(choices,1)

        possible_choices = choices[(choices[:,"as"] .== pick_as) .& (choices[:,"fpe"] .== pick_fpe),:]
        #see if as and fpe works for the others. 
        #if not, then move on to the next pick
        #if yes, then keep it

        #pick the first one that works
        #if none works,

        println(possible_choics)
    end


    global nc = size(choices,1) #number of choices
    global set_fc′ =Vector{Float64}(undef, nc)
    global set_as  = Vector{Float64}(undef, nc)
    global set_ec  = Vector{Float64}(undef, nc)
    global set_fpe = Vector{Float64}(undef, nc)
    global set_pu  = Vector{Float64}(undef, nc)
    global set_mu  = Vector{Float64}(undef, nc)
    global set_vu  = Vector{Float64}(undef, nc)
    global set_embodied = Vector{Float64}(undef, nc)
    global set_element  = Vector{Int64}(undef, nc)

    for j in eachindex(choices) 
        set_fc′[j] = choices[j]["fc"]
        set_as[j] = choices[j]["as"]
        set_ec[j] = choices[j]["ec"]
        set_fpe[j] = choices[j]["fpe"]
        set_pu[j] = choices[j]["pu"]
        set_mu[j] = choices[j]["mu"]
        set_vu[j] = choices[j]["vu"]
        set_embodied[j] = choices[j]["embodied"]
        set_element[j] = parse(Int,choices[j]["element"])
        @assert set_element[j] == element_idx
    end

    min_embodied = minimum(set_embodied)
    idx_min_embodied = findall(x->x==min_embodied, set_embodied)
    for k in eachindex(idx_min_embodied) 
        fc' = set_fc′[idx_min_embodied[k]]
        as = set_as[idx_min_embodied[k]]
        ec = set_ec[idx_min_embodied[k]]
        fpe = set_fpe[idx_min_embodied[k]]
        pu = set_pu[idx_min_embodied[k]]
        mu = set_mu[idx_min_embodied[k]]
        vu = set_vu[idx_min_embodied[k]]
        embodied = set_embodied[idx_min_embodied[k]]
        element = set_element[idx_min_embodied[k]]

    end







    


        #select constant fpe, fc' as


        for si in eachindex()



        end
        #reset
        element_decisions = Bool.(zeros(ns,1))
    end







            
optimum = Vector{Dict{String, Float64}}(undef, size(data,1))

for i in eachindex(decisions)
    opt_idx = decision[i]

    optimum[i] = outvod[i][opt_idx]
end


#         get the minimum embodied carbon configuration


#         #sort by embodied carbon. 
#         ec = #find a way to get the minimum one. 

#         #loop the same fc' 
    
#         #get mid span
#         #look into the possible choices.
#     end

# end