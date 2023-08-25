"""
Post processing the choices.
"""
# function postprocess(outvod, data)
    # go through each element
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
        element_idx = elements[i] #element index (maybe not by the index i)
        sections = elements_to_sections[elements_idx] # all section indices that associate with the element
        println(sections)
        # number of sections in that element
        ns = size(sections,1)
        # println(ns)

        #section should be in consecutive order.
        ns_min = minimum(sections) 
        ns_max = maximum(sections)
        # @show ns_min,ns_max, ns
        @assert ns_max - ns_min + 1 == ns

        element_decisions = Bool.(zeros(ns,1))
        #start at mid span of the section
        if mod(ns,2) == 0 
            midspan_idx =  ns/2 + ns_min -1
        else
            midspan_idx = (ns+1)/2 + ns_min -1
        end

        #then idx += 1 until the end of the section (ns_max)
        #idx is for the section idx
        @show idx = Int(midspan_idx)

        while !prod(element_decisions)
            



        global choices = outvod[idx]
        nc = size(choices,1) #number of choices
        global set_fc′ =Vector{Float64}(undef, nc)
        global set_as = Vector{Float64}(undef, nc)
        global set_ec = Vector{Float64}(undef, nc)
        global set_fpe = Vector{Float64}(undef, nc)
        global set_pu = Vector{Float64}(undef, nc)
        global set_mu = Vector{Float64}(undef, nc)
        global set_vu = Vector{Float64}(undef, nc)
        global set_embodied = Vector{Float64}(undef, nc)
        global set_element = Vector{Int64}(undef, nc)

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
@show idx
@show set_element[j]
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