  # create a dictionary with index to bar area to allow easy execution of for loop
  index_to_bar_area = Dict{Int64,Float64}(
    1 => 0.11, 
    2 => 0.2,
    3 => 0.31, 
    4 => 0.44, 
    5 => 0.6,
    6 => 0.79, 
    7 => 1.0, 
    8 => 1.27,
    9 => 1.56,
    10 => 2.25,
    11 => 4,
    )

# match the index to actual bar numbers
index_to_bar_num = Dict{Int64,String}(
    1 => "#3",
    2 => "#4",
    3 => "#5",
    4 => "#6",
    5 => "#7",
    6 => "#8",
    7 => "#9",
    8 => "#10",
    9 => "#11",
    10 => "#14",
    11 => "#18",
    )

# first make a dictionary of using 1 bar only 
bar_combination_and_area = Dict{String,Vector{Float64}}(
    "#3" => [0.11], 
    "#4" => [0.20], 
    "#5" => [0.31],
    "#6" => [0.44], 
    "#7" => [0.60],
    "#8" => [0.79],
    "#9" => [1.00],
    "#10" => [1.27],
    "#11" => [1.56], 
    "#14" => [2.25], 
    "#18" => [4.00],
    )

@assert length(index_to_bar_num) == length(index_to_bar_area)
@assert length(index_to_bar_num) == length(bar_combination_and_area)

N = length(index_to_bar_area)
# add the two same bars combination into the dictionary above
# doesn't need to calculate all combinations because the reinforcement needs to be symmetry
# meaning if there's only 2 bars, they have to be the same size
for each_rebar in 1:N
    # total_steel_area = index_to_bar_area[each_rebar] * 2
    name = string( index_to_bar_num[each_rebar], "_", index_to_bar_num[each_rebar])
    areas = [index_to_bar_area[each_rebar],index_to_bar_area[each_rebar]]
    push!(bar_combination_and_area, name => areas)
end

# add three bars combination into the dictionary 
# only need to account for combinations with two same digits such as 122, since it needs symmetry 
for first_rebar in 1:N
    for second_rebar in 1:N
        name = string( index_to_bar_num[first_rebar], "_", index_to_bar_num[second_rebar], "_", index_to_bar_num[second_rebar])
        total_steel_area =vcat([index_to_bar_area[first_rebar]], repeat([index_to_bar_area[second_rebar]],2))
           
        push!(bar_combination_and_area, name => total_steel_area)
    
    end
end

# add four bars combination into the dictionary 
# This could be done by 2 ways, a a b b , a a a a
for first_rebar in 1:N
    #repeat four time
    repeatpart = "_"*string(index_to_bar_num[first_rebar])
    name = string(index_to_bar_num[first_rebar],repeatpart^4)
    total_steel_area = repeat([index_to_bar_area[first_rebar]], 4)
    push!(bar_combination_and_area, name => total_steel_area)

    for second_rebar in (first_rebar+1):N
        repeatpart1 = "_"*string(index_to_bar_num[first_rebar])
        name1 = string(index_to_bar_num[first_rebar],repeatpart1^2)

        repeatpart2 = "_"*string(index_to_bar_num[second_rebar])
        name2 = string(index_to_bar_num[second_rebar],repeatpart2^4)

       
        total_steel_area =vcat([index_to_bar_area[first_rebar]], repeat([index_to_bar_area[second_rebar]],2))
           
        push!(bar_combination_and_area, name => total_steel_area)
    
    end
end
println("Might have to reformat the bars again, but it's ok for now.")
for i in bar_combination_and_area
    println(i)
end

rebars = bar_combination_and_area


