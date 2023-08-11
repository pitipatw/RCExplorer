
"""
Get inertia and cg of the given section
inputs:
    eval_pts: matrix of grid points to evaluate
    c: y position of the neural axis
    dx: x spacing
    dy: y spacing
outputs: 
    area : area of the section
    inertia: moment of inertia of the section around y = c
    cgy: y position of the centroid
"""
function secprop(eval_pts::Matrix{Float64} , c::Float64; dx = 1.0, dy = 1.0)
    #find moment of inertia of the point related to an axis y = c
    # and cgy.
    area = dx*dy*size(eval_pts)[1]
    I = Vector{Float64}(undef, size(eval_pts)[1])
    # Cgx = Vector{Float64}(undef, size(eval_pts)[1]) #Not interested now
    Cgy = Vector{Float64}(undef, size(eval_pts)[1])
    dxdy = dx*dy
    area = size(eval_pts)[1]*dxdy
    # println("dx: ", dx, " dy: ", dy)
    # println("Area: ", area)

    # @time @Threads.threads 
    for i =1:size(eval_pts)[1] #could do in strip
        # x = eval_pts[i,1]
        y = eval_pts[i,2]
        r = (y-c)
        I[i] = r^2*dxdy
        # Cgx[i] = x*dxdy
        Cgy[i] = y*dxdy
    end
    # cgx = sum(Cgx)
    cgy = sum(Cgy)/area
    inertia = sum(I)
    return (area, inertia, cgy)
end

"""
Get the depth of the section given eval points and target area
"""
function getdepth(p_inpoly::Matrix{Float64}, target_a::Float64, ys::Vector{Float64}; tol::Float64 = 0.1, dx = 1.0, dy = 1.0)
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