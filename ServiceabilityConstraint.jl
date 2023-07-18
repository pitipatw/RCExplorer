module ServiceabilityConstraint
using Distributions
using Makie, GLMakie

#Assuming non crack, we will use I_g(gross Inertia) for calculation of beam defelction
# Setting up Equations
"""
Find the gross Inertia for a rectanglular section
Table 8-2 from EB070-07.pdf 
or Section 5, page 190 of RC Mechanics and Design 6th textbook
"""
function find_I_g(b, h)
    return (b * h^3) / 12
end

"""
Find the gross Inertia for a T section
"""
function find_I_g(b, b_w, h_f, h, y_t)
    return ((b - b_w) * h_f^3) / 12 + (b_w * h^3) / 12 + (b - b_w) * h_f * ((h - h_f) / (2 - y_t))^2 + (b_w * h * (y_t - (h / 2))^2)
end

"""
Find y_t(Distance from centroidal axis of gross section, neglecting reinforcement, to tension face)
Used in finding the gross Inertia for a T section
"""
function find_y_t(h, b, b_w, h_f)
    return h - (1 / 2) * ((b - b_w) * h_f^2 + (b_w * h^2)) / ((b - b_w) * h_f + (b_w * h))
end

"""
Modulus of elasticity for w_c(unitweight) between 1440 and 2560 kg/m^3
ACI 19.2.2.1
"""
function find_E_c(w_c, fc′)
    return (w_c)^1.5 * 0.043 * sqrt(fc′) # in MPa
end

"""
Modulus of elasticity for normalweight concrete
ACI 19.2.2.1
"""
function find_E_c(fc′)
    return 4700 * sqrt(fc′) # in MPa
end


"""
Ratio of A_s′(Area of compressive reinforcement) to bd
Calculate at midspan for simple and continuous spans and at the support for cantilevers 
ACI 24.2.4.1.2
"""
function find_ρ′(A_s′, b, d)
    return A_s′ / (b * d)
end

"""
Find time-dependent factor for sustained load
"""
function find_ξ(sustained_load_duration_in_months::Int64)
    if sustained_load_duration_in_months == 3
        return 1.0
    elseif sustained_load_duration_in_months == 6
        return 1.2
    elseif sustained_load_duration_in_months == 12
        return 1.4
    elseif sustained_load_duration_in_months >= 60
        return 2.0
    else
        return "Round to 3,6,12, 60 or more months"
    end
end

"""
Multiplier used for additional deflection due to long-term effects
"""
function find_λ_Δ(ξ, ρ′)
    return ξ / (1 + (50 * ρ′))
end

"""
Calculating Deflection of Simply Supported, Uniform Distributed Load
w in here is load
"""
function find_δ(w, x, L, E, I)
    return -(w * x) * (L^3 - (2 * L * x^2) + x^3) / (24 * E * I)
end

"""
Calculating the Maximum Deflection of simply supported, uniform Distribued load
which is at x= L/2
"""
function find_max_δ(w, L, E, I)
    return (5 * w * L^4) / (384 * E * I)
end

"""
Change ft to inches
"""
function convert_ft_to_in(ft)
    return ft * 12
end

function main()

    # Define Initial values
    Beam_Span_Length = rand(Uniform(1, 250), 25, 1)
    println(Beam_Span_Length)
    fc′ = 4000.0 #psi
    b_w = 12.0 #in
    h_f = 6.0 #in
    h = 24.0 #in
    d = h - 2.5 #in
    M_u = 130000.0 #ft
    ϕ = 0.9 #no unit
    f_y = 60000.0 #psi
    j = 0.95 # assumption
    spacing_between_beams = 12.0 #ft
    D = rand(Uniform(0, 10), 15, 1) #k/ft
    L = 0.15 #k/ft # kip/ square feet # kip= 1000 pound force

    ## Deflection Limitation from Table 24.2.2 from ACI
    # Flat roofs (Not supporting/ not attached to elements likely to be damaged by large deflection)
    # l/180
    # Floor (Not supporting/ not attached to elements likely to be demaged by large deflection)
    # l/360
    # Roof or floors (supporting/ attached to nonstructural elements likely to be damaged by large deflection)
    # l/480
    # Roof or floors (supporting/ attached to nonstructural elements NOT likely to be damaged by large deflection)
    # l/240

    total_combinations = length(Beam_Span_Length) * length(D)
    values_of_max_δ = Array{Float64,1}()
    plotting_points = Matrix{Float64}(undef, total_combinations, 2)
    count = 0

    #Execution
    for each_length in Beam_Span_Length
        for each_dead_load in D
            count += 1
            effective_width_b1 = convert_ft_to_in(each_length) / 4
            effective_width_b2 = b_w + (2 * 8 * h_f)
            effective_width_b3 = (convert_ft_to_in(spacing_between_beams))

            b = min(effective_width_b1, effective_width_b2, effective_width_b3)

            y_t = find_y_t(h, b, b_w, h_f)
            I_g = find_I_g(b, b_w, h_f, h, y_t)
            E = find_E_c(fc′)

            # Using basic combination 2 from 2.3.2 of ASCE standard
            # Using just dead loads first

            required_design_strength = 1.4 * each_dead_load
            plotting_points[count, :] = [each_length, each_dead_load]
            max_δ = find_max_δ(required_design_strength, each_length, E, I_g)
            push!(values_of_max_δ, max_δ)
            println("mas δ is ", max_δ)

            deflection_limit = each_length / 480
            println("deflection limit is ", deflection_limit)

            if max_δ < deflection_limit
                println(true)
            else
                println(false)
            end
        end
    end
    #visualization
    GLMakie.activate!()
    # tell julia to use GLMakie
    f = Figure(resolution=(1200, 800)) #initialize with resolution
    ax = Axis3(f[1, 1], xlabel="Beam Length [In]", ylabel="Dead Load[kip/square ft]", zlabel="max deflection")
    #initialize 3d axis with labels
    scatter!(ax, plotting_points[:, 1], plotting_points[:, 2], values_of_max_δ, color=values_of_max_δ) #plot all data

    return f


end

end #module ServiceabilityConstraint

ServiceabilityConstraint.main()