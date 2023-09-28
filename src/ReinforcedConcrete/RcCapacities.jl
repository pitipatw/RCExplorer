function findPu(c::ConcreteSection)
    return 0.65*0.85 * (c.fc′ * (c.ag - sum(c.rebars.ast))) + sum(c.rebar.fy .* c.rebar.ast)
end

function find_Mu(c::ConcreteSection)
    d = c.rebars.y
    ϵc = 0.003 ; ϵs = 0.005 #assume steel yield
    #find c 
    c =  ϵc/(ϵc + ϵs)*d  # simply 3/8*d
    β1 = clamp(0.85- 0.05*(fc′-28)/7, 0.65,0.85)
    a = β1*c
    return 0.9*sum(c.rebar.as .* c.rebar.fy .* (c.rebar.d .- (a/2)))
end

# function find_Vu(c::ConcreteSection)
#     println("Working in progress")
#     @assert 1 = 2
#     return 0.0
# end
