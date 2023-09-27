"""
depth here has to be an absolute depth
"""
function sutherland_hodgman(section::CompoundSection, depth::Float64; return_section = false)

    #get absolute depth first
    sections = section.solids
    sections_out = Vector{SolidSection}(undef, length(sections))
    for i in eachindex(sections) 
        sections[i] = sections[i]
        clipped_section_i = AsapSections.sutherland_hodgman_abs(sections[i], depth; return_section = true)
        sections_out[i] = clipped_section_i
    end

    if return_section
        return CompoundSection(sections_out)
    else
        return sections_out
    end

end

ranges = 1.:1.:200.
output = Vector{Float64}()
for i in 1.:1.:200.
clipped = sutherland_hodgman(compoundsection, i; return_section = true)
println(clipped.area)
end


clipped = sutherland_hodgman(compoundsection, 150.; return_section = true)

ymax = compoundsection.ymax
ymin = compoundsection.ymin
f1 = Figure(resolution = (800,800))
lim = (ymin, -ymin, ymin, ymax) .* 1.05
ax1 = Axis(f1[1,1], aspect = DataAspect(), limits = lim)
ax2 = Axis(f1[1,2], aspect = DataAspect(),limits = lim)
for i in eachindex(compoundsection.solids)
    scatter!(ax1, compoundsection.solids[i].points)

end

for i in eachindex(clipped.solids)
    scatter!(ax2, clipped.solids[i].points)

end

f1

