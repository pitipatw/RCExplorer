module EmbodiedCarbon
## The script to calculate embodied carbon, forces capacity, and serviceability constrain

#define packages that will be used
using Distributions
using Makie, GLMakie
using GeometryBasics
using StatsPlots

#setting up equations
"""
Equation for determining the required steel area in a singly reinforced section
5-16 RC textbook
"""
function find_A_s(M_u::Float64, ϕ::Float64, f_y::Float64, d::Float64, a::Float64)
    return M_u / (ϕ * f_y * (d - (a / 2)))
end
"""
5-16 Rc textbook equation but with different variables
"""
function find_A_s(; M_u::Float64, ϕ::Float64, f_y::Float64, j::Float64, d::Float64)
    return M_u / (ϕ * f_y * (j * d))
end

"""
Equation for minimum A_s
"""
function find_A_smin(fc′::Float64, b_w::Float64, d::Float64, f_y::Float64)
    return (3 * sqrt(fc′) * b_w * d) / f_y
end


"""
Equation to determine the depth of the compression stress block, a
This equation can be used to find A_s in 5-16
"""
function find_a(A_s, f_y, fc′, b)
    return (A_s * f_y) / (0.85 * fc′ * b)
end



"""
input the calculated A_s value and match it with discrete rebar combinations
return the rebar combination and the steel area
"""
function give_minimum_A_s_rebar_combination(A_s::Float64)

    # create a dictionary with index to bar area to allow easy execution of for loop
    index_to_bar_area = Dict(1 => 0.11, 2 => 0.2, 3 => 0.31, 4 => 0.44, 5 => 0.6,
        6 => 0.79, 7 => 1, 8 => 1.27, 9 => 1.56, 10 => 2.25, 11 => 4)

    # match the index to actual bar numbers
    index_to_bar_num = Dict(1 => "No.3", 2 => "No.4", 3 => "No.5", 4 => "No.6", 5 => "No.7", 6 => "No.8",
        7 => "No.9", 8 => "No.10", 9 => "No.11", 10 => "No.14", 11 => "No.18")

    # first make a dictionary of using 1 bar only 
    bar_combination_and_area = Dict("No.3" => 0.11, "No.4" => 0.2, "No.5" => 0.31, "No.6" => 0.44, "No.7" => 0.6,
        "No.8" => 0.79, "No.9" => 1, "No.10" => 1.27, "No.11" => 1.56, "No.14" => 2.25, "No.18" => 4)

    # add the two same bars combination into the dictionary above
    # doesn't need to calculate all combinations because the reinforcement needs to be symmetry
    # meaning if there's only 2 bars, they have to be the same size
    for each_rebar in 1:11
        total_steel_area = index_to_bar_area[each_rebar] * 2
        push!(bar_combination_and_area, string("2 ", index_to_bar_num[each_rebar]) => total_steel_area)
    end

    # add three bars combination into the dictionary 
    # only need to account for combinations with two same digits such as 122, since it needs symmetry 
    for first_rebar in 1:11
        for second_rebar in 1:11
            total_steel_area = index_to_bar_area[first_rebar] + (2 * index_to_bar_area[second_rebar])
            push!(bar_combination_and_area, string(index_to_bar_num[first_rebar], " & 2 ", index_to_bar_num[second_rebar]) => total_steel_area)
        end
    end

    A_s_final = 0.0
    bar_size = "No.0"
    smallest_diff_btwn_required_A_s_and_combination_A_s = 99999
    for (BarSize, ComboArea) in bar_combination_and_area
        current_diff = ComboArea - A_s
        if current_diff < smallest_diff_btwn_required_A_s_and_combination_A_s && current_diff > 0
            smallest_diff_btwn_required_A_s_and_combination_A_s = current_diff
            A_s_final = ComboArea
            bar_size = BarSize
        end
    end
    return [bar_size, A_s_final]
end


"""
P0 22.4.2.2
Nominal Axial Compressive Strength
fc′= specified compressive strength of concrete
Ast= Area of reinforcement/ steel (A_s)
Ag= Area of concrete cross section
fy= specified yield strength for nonprestressed reinforcement
"""
function find_P0(fc′::Number, Ag::Float64, Ast::Float64, fy::Float64)
    return 0.85 * (fc′ * (Ag - Ast)) + (fy * Ast)
end

"""
Nominal Moment Capacity
"""
function find_Mn(A_s, f_y, d, a)
    return A_s * f_y * (d - (a / 2))
end

"""
Shear Capacity
"""
function find_shear_capacity()
    return phi * V_n
end


"""
Calculate the Embodied Carbon per unit
For concrete: ~2400 kg/cu.m
For rebar: ~7850 kg/cu.m
"""
function CalculateEmbodiedCarbon(b, h, length)
    MaterialVolume = b * h * length
    EmbodiedCarbon = coefficient * MaterialVolume
    return EmbodiedCarbon
end


## meeting update
# geometry will be fixed, input the steel position and steel size range
function find_fc′(A_s::Float64, f_y::Int64, d::Float64, b::Float64, j::Float64)
    (bar_size, corresponding_A_s) = give_minimum_A_s_rebar_combination(A_s)
    fc′ = (corresponding_A_s * f_y) / (-2 * 0.85 * d * b * (j - 1))
    return [fc′, bar_size]
end


function main()
    ## Define initial value

    # Later, this function will execute these inputs
    # 1.Section width (b)
    # 2.Section height (h)
    #   a.Reinforcement position (d) -> could be fixed to h - 50mm (so we don’t have too much variables)
    # 3.Number of reinforcement bars (let’s do 1 to 8 bars, at most)
    # 4.Reinforcement bars area (let’s assume same area for all bars, using the discrete bar sizes you already have in your script)
    # 5.Beam length (l)(This is crucial for serviceability analysis and weight comparison)

    b = 5.0
    h = 5.0
    d = h - 0.05
    j = 0.95
    f_y = 60000 #psi
    l = 10
    A_s = rand(Uniform(0, 4), 30, 1)

    value_to_plot = Matrix{Float64}(undef, length(A_s), 2)

    bar_num_list = Array{String,1}()
    for i = 1:length(A_s)
        (fc′, bar_num) = find_fc′(A_s[i], f_y, d, b, j)
        value_to_plot[i, 1] = A_s[i]
        value_to_plot[i, 2] = fc′
        push!(bar_num_list, bar_num)
    end

    #visualization
    #GLMakie.activate!()
    # tell julia to use GLMakie
    f1 = Figure(resolution=(800, 800))
    ax1 = Axis(f1[1, 1], xlabel="A_s", ylabel="fc′")#, aspect = DataAspect(), xgrid = false, ygrid = false)
    GLMakie.scatter!(ax1, value_to_plot[:, 1], value_to_plot[:, 2], color=:green)

    return f1



end
end


EmbodiedCarbon.main()