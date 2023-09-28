function find_Pu(c::ConcreteSection)
    return 0.65*0.85 * (c.fc′ * (c.geometry.area - sum(c.rebars.ast))) + sum(c.rebars.fy .* c.rebars.ast)
end

function find_Mu(c::ConcreteSection)
    d = c.rebars.y
    ϵc = 0.003 ; ϵs = 0.005 #assume steel yield
    #find c 
    c_ =  ϵc/(ϵc + ϵs)*d  # simply 3/8*d
    β1 = clamp(0.85- 0.05*(c.fc′-28)/7, 0.65,0.85)
    a = β1*c_
    return 0.9*sum(c.rebars.ast .* c.rebars.fy .* (c.rebars.d .- (a/2)))
end

# function find_Vu(c::ConcreteSection)
#     println("Working in progress")
#     @assert 1 = 2
#     return 0.0
# end
