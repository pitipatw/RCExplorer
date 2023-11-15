"""
Post processing the choices.
"""
# function postprocess(outvod, data)

#preparing the data
#sort outvod by embodied carbon-> 




#element index container
elements_all = Vector{Int64}(undef, size(data, 1))
#element index to section index
elements_to_sections = Dict{Int64,Vector{Int64}}()
for i in eachindex(data)
    elements_all[i] = data[i]["e_idx"]
    if haskey(elements_to_sections, elements_all[i])
        elements_to_sections[elements_all[i]] = vcat(elements_to_sections[elements_all[i]], i)
    else
        elements_to_sections[elements_all[i]] = [i]
    end
end

elements = collect(keys(elements_to_sections))

choices_sorted = Vector{DataFrame}(undef, size(data, 1))
for i in eachindex(choices_sorted)
    temp = DataFrame(outvod[i])
    temp[!, "order"] = 1:size(temp, 1)
    choices_sorted[i] = sort(temp, ["embodied", "ec", "as", "fpe", "fc"])
end

# decision vector, index based on the available choices of each section.
decisions = ones(size(data, 1))
#loop each element
for i in eachindex(elements)
    #element index (in case elements is not in order)
    element_idx = elements[i]
    #all section indices that associate with the element
    sections = elements_to_sections[element_idx]
    println("Element: $element_idx")
    println("   Sections: $sections")
    # number of sections in that element
    ns = size(sections, 1)

    #section should be in consecutive order.
    ns_min = minimum(sections)
    ns_max = maximum(sections)
    @show ns_min, ns_max, ns
    @assert ns_max - ns_min + 1 == ns

    #start at mid span of the section
    if mod(ns, 2) == 0
        mid_section_idx = ns / 2 + ns_min - 1
    else
        mid_section_idx = (ns + 1) / 2 + ns_min - 1
    end
    mid_section_idx = Int(mid_section_idx)
    println("Mid section of e: $element_idx is $mid_section_idx")

    #choices for mid section [a DataFrame]
    mid_section_choices_sorted = choices_sorted[mid_section_idx]
    println("There are $(size(mid_section_choices_sorted,1)) choices for mid section $mid_section_idx")

    #current choice for mid section
    pick_idx_mid = 1

    #initiate section index
    current_section_idx = ns_min
    #if prod(element_decisions) == 1 (true), then all sections are resolved.
    element_decisions = Bool.(zeros(ns, 1))
    # element_selections = Vector{Int64}(undef, ns)
    counter = 0
    while !prod(element_decisions)
        counter += 1
        if counter >= 100000
            println("No solution found within current counter\n consider increasing the counter limit")
            break
        end

        if current_section_idx > ns_max
            #reach the last section, and still can't find solution
            #Use next mid section choice.
            pick_idx_mid += 1
            #reset section index.
            current_section_idx = ns_min

            if pick_idx_mid > size(mid_section_choices_sorted, 1)
                println("Unresolved sections for elements $element_idx")
                break
            end

        elseif current_section_idx != mid_section_idx #skip mid section
            pick_mid_choice = mid_section_choices_sorted[pick_idx_mid, :]
            pick_mid_fc = pick_mid_choice["fc"]
            pick_mid_as = pick_mid_choice["as"]
            pick_mid_fpe = pick_mid_choice["fpe"]
            pick_idx_mid_abs = pick_mid_choice["order"]
            decisions[mid_section_idx] = pick_idx_mid_abs
            #find as and fpe in the current section 
            current_section_choices = choices_sorted[current_section_idx]

            #only get the choices that has as and fpe
            feasible_choices = current_section_choices[(current_section_choices[:, "as"].==pick_mid_as).&(current_section_choices[:, "fpe"].==pick_mid_fpe), :]

            if size(feasible_choices, 1) == 0
                println("Cant find for section: $current_section_idx, move on to the next section")
                #if no choices, then move on to the next choices for the mid section
                #and start all over again.
                current_section_idx = ns_min
                pick_idx_mid += 1

                continue
            else
                #if there are available choices 
                decisions[current_section_idx] = feasible_choices[1, "order"]
                # element_selections[current_section_idx - ns_min + 1] = pick_idx
                element_decisions[current_section_idx-ns_min+1] = true
                #move on to the next section in this element
                current_section_idx += 1
            end
        else
            #current section is mid section
            current_section_idx += 1
        end
    end

end

# return decisions
# end

#visualize decisions vector
#go through each decision, get
# fc', as, fpe, ec, embodied.
traces = Vector{Any}(undef, size(data, 1))
set_of_results = []
for i in eachindex(elements)
    element = elements[i]
    sections = elements_to_sections[element]
    results = Matrix{Float64}(undef, size(sections, 1), 5)
    for j in eachindex(sections)
        section = sections[j]
        decision_idx = Int(decisions[section])
        decision = choices_sorted[section][decision_idx, :]
        results[j, :] = [decision["fc"], decision["as"], decision["fpe"], decision["ec"], decision["embodied"]]
    end
    push!(set_of_results, results)
end


#plot the result
traces = Vector{GenericTrace{Dict{Symbol,Any}}}()
L = 192
#have to slice results into elements
for i in eachindex(elements)
    element = elements[i]
    sections = elements_to_sections[element]
    xpos = 50.0 * (0:size(sections, 1))
    trace1 = scatter(; x=xpos, y=-set_of_results[i][:, 4] .* L, mode="lines+markers", name="ec")
    push!(traces, trace1)
end
layout = Layout(; title="Eccentricity plot",
    yaxis_range=[-1.3, 0] .* L, legend_y=0.5, legend_yref="paper",
    legend=attr(family="Arial, sans-serif", size=20,
        color="grey"))
p1 = plot(traces, layout)

traces = Vector{GenericTrace{Dict{Symbol,Any}}}()

#have to slice results into elements
for i in eachindex(elements)
    element = elements[i]
    sections = elements_to_sections[element]
    xpos = 50.0 * (0:size(sections, 1))
    trace1 = scatter(; x=xpos, y=set_of_results[i][:, 3], mode="lines+markers", name="ec")
    push!(traces, trace1)
end
layout = Layout(; title="fpe plot", legend_y=0.5, legend_yref="paper",
    legend=attr(family="Arial, sans-serif", size=20,
        color="grey"))
p2 = plot(traces, layout)


traces = Vector{GenericTrace{Dict{Symbol,Any}}}()
#have to slice results into elements
for i in eachindex(elements)
    element = elements[i]
    sections = elements_to_sections[element]
    xpos = 50.0 * (0:size(sections, 1))
    trace1 = scatter(; x=xpos, y=set_of_results[i][:, 2], mode="lines+markers", name="ec")
    push!(traces, trace1)
end
layout = Layout(; title="as plot", legend_y=0.5, legend_yref="paper",
    legend=attr(family="Arial, sans-serif", size=20,
        color="grey"))
p3 = plot(traces, layout)



p = [p1 p2 p3]
relayout!(p, title_text="Optimum result")










optimum = Vector{Dict{String,Float64}}(undef, size(data, 1))

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