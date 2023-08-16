"""
Get the depth of the section given eval points and target area
This is for the full points evaluation
"""
function getdepth(p_inpoly::Matrix{Float64}, target_a::Float64, ys::Vector{Float64}; 
    tol::Float64 = 0.1, 
    dx = 1.0, 
    dy = 1.0)

    
    y_top = ys[1]
    y_bot = ys[2]
    ub = y_top - y_bot
    lb = 0.0
    depth = (lb + ub) / 2 #initializing a variable
    counter = 0
    while true
        counter +=1 
        if counter > 1000 
            println("Exceed 1000 iterations, exiting the program...")
            return depth, chk
        end

        #more efficient by adding more points?
        #if the points are sorted, we could continue?, but with each depth.

        global chk = Vector{Bool}(undef, size(p_inpoly)[1])
        c_pos = y_top - depth
        ys = p_inpoly[:, 2]
        chk = ys .> c_pos
        
        com_pts = p_inpoly[chk, :]
        area = dx * dy * size(com_pts)[1]
        diff = abs(area - target_a) / target_a
        if diff < tol
            # println("the depth is at y = ", depth)
            # println("tol is: ", diff)
            break
        elseif area - target_a > tol
            ub = depth
            depth = (lb + ub) / 2
        elseif area - target_a < tol
            lb = depth
            depth = (lb + ub) / 2
        end

    end

    return depth, chk
end