using CSV

standard_sizes = CSV.File(joinpath(@__DIR__,"standard_sizes.csv"), header = false) |> Dict
new_dict= Dict{String,Float64}()
for (k,v) in standard_sizes
    push!(new_dict, string(k)=> v)
end
standard_sizes = new_dict

function get_combinations(standard_sizes::Dict{String,Float64})
    combinations= Dict{String,Vector{Float64}}()
    map = 0
    # @show standard_sizes
    n = length(standard_sizes)
    #single bar
    for (k,v) in standard_sizes
        push!(combinations, k=> [v])
    end

    #double bars (same bar)
    for (k,v) in standard_sizes
        push!(combinations, k*"_"*k => [v,v])
    end

    #tripple bars (aaa, abb)
    for (k1,v1) in standard_sizes
        for (k2,v2) in standard_sizes
            push!(combinations, k2*"_"*k1*"_"*k2 => [v2,v1,v2])
        end
    end

    #quad bars (aabb, aaaa)
    for (k1,v1) in standard_sizes
        for (k2,v2) in standard_sizes
            if k2*"_"*k2*"_"*k1*"_"*k1 ∉ keys(combinations)
                push!(combinations, k2*"_"*k1*"_"*k1*"_"*k2 => [v2,v1,v1,v2])
            end
        end
    end
    map = Dict(1:length(combinations) .=> collect(keys(combinations)))
    # @assert length(combinations) == n + n + factorial(n)/factorial(n-2) + factorial(n)/factorial(n-2)/2
    return combinations, map
end

bar_combinations,map = get_combinations(standard_sizes)

function get_rebar()

#get_rebar_combination()
    #Rebars will be single layer, 50mm up from the bottom
    #y = -h + 50 [mm]
    for (k,r_idx) in map
        # println(typeof(r_idx))
        # println(bar_combinations)
        areas = bar_combinations[r_idx]
        ds = parse.(Float64,split(map[k],"_")) #vector of diameters
        #spacing check
        nr = length(ds) #number of rebars
        spacing = maximum([40, 1.5*maximum(ds)])
        spacing_check = w > ( 2*covering + sum(ds) + (nr-1)*spacing )
    end
end
