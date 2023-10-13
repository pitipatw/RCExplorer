"""
    Design equation: 
        Mᵤ= ϕAₛfy(d-a/2)
    
    We enforce tension-controlled section
    i.e., ϵc = 0.003 and ϵs = 0.005 -> ϕ = 0.9
    We will have 
        c = 3/8d
    a = β1c , where β1 is a function of fc′
    
    Mᵤ= ϕAₛfy(d-a/2) becomes 
      = 0.9Aₛfy( d - β1(3/8)d/2 )

    Then, we can impose a sc

"""
#The design space
ρs = 0.01:0.005:0.08 #reinforcement ratio 
d = 200.:25.:500.
bd_ratio = 0.5:0.05:1 #b/d ratio b = bd_ratio*d
const fy = 420.


"""
Simplified equation (in psi and kips)
As = Mu/(4d)
"""
function simp_eq(Mu::Float64, d::Float64)
    As = Mu/4/d
    return As
end


