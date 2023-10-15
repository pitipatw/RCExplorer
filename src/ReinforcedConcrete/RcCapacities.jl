using AsapSections
function find_Pu(c::ConcreteSection)
    return 0.65*0.85 * (c.fc′ * (c.geometry.area - sum(c.rebars.ast))) + sum(c.rebars.fy .* c.rebars.ast)
end
function find_Mu(c::ConcreteSection)
    area_req = sum(c.rebars.ast .* c.rebars.fy)/(c.fc′*0.85)
    a = depth_from_area(c.geometry,area_req);
    β1 = clamp(0.85- 0.05*(c.fc′-28)/7, 0.65,0.85)
    c_ = a/β1
    d = c.geometry.ymax - c.geometry.ymin
    ϵs = 0.003 * (d - c_) / c_
    ϕ = clamp(0.65 + 0.25 * (ϵs - 0.002) / 0.003, 0.65, 0.90)
    return ϕ*sum(c.rebars.ast .* c.rebars.fy .* (c.rebars.d .- (a/2)))
end

# function find_Vu(c::ConcreteSection)
#     println("Working in progress")
#     @assert 1 = 2
#     return 0.0
# end
