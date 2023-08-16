L = 200.0
t = 20.0
lc = 10.0

nodes = fullpixel(L, t, Lc)

pts = fillpoints(nodes, 0.5,0.5)

pixelpts = pts[pointsinpixel(nodes,pts),:]

using Makie, GLMakie

f1 = Figure(resolution = (800, 600))
ax1 = Axis(f1[1, 1], xlabel = "x", ylabel = "y", aspect = DataAspect())
p1 = scatter!(ax1, pixelpts[:,1],pixelpts[:,2], color = :blue )


total_area = 0.5*0.5*length(pixelpts[:,1])
dx = 0.5
dy = 0.5
tol = 1e-3
target_a = area1
y_top = maximum(nodes[:,2])
y_bot = minimum(nodes[:,2])
ub = y_top - y_bot
lb = 0.0
depth = (lb + ub) / 2 #initializing a variable
counter = 0
global  ys = pixelpts[:, 2]
while true
    counter +=1 
    if counter > 1000 
        println("Exceed 1000 iterations, exiting the program...")
        return depth, chk
    end

    #more efficient by adding more points?
    #if the points are sorted, we could continue?, but with each depth.

    global chk = Vector{Bool}(undef, size(pixelpts)[1])
    c_pos = y_top - depth

    chk = ys .> c_pos
    
    com_pts = pixelpts[chk, :]
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
chk
p2 = scatter!(ax1, pixelpts[chk,1],pixelpts[chk,2], color = :red )
f1


#for the csv file 

total_area = 0.5*0.5*length(pixelpts[:,1])
dx = 0.5
dy = 0.5
tol = 1e-3
target_a = 15000.0
y_top = maximum(nodes[:,2])
y_bot = minimum(nodes[:,2])
ub = y_top - y_bot
lb = 0.0
depth = (lb + ub) / 2 #initializing a variable
counter = 0
global  ys = pixelpts[:, 2]
ys_single = unique(ys)
out = Matrix{Float64}(undef ,length(ys_single),3)
for i in eachindex(ys_single)
    yi = ys_single[i]
    # c_pos = y_top - depth
    chk = ys .> yi
    com_pts = pixelpts[chk, :]
    ydx = ys[chk].*(dx*dy)
    
    area = dx * dy * size(com_pts)[1]
    cg = sum(ydx)/area
    out[i,:] = [yi, area, cg]

end

CSV.write("pixel-$L-$t-$Lc.csv", DataFrame(out ,:auto), header = false)
data = CSV.read("pixel-$L-$t-$Lc.csv", header = false, DataFrame)


ycomp = data[300,1]
cg = data[300,3]
area1 = data[300,2]

#plotting
p2 = scatter!(ax1,0, cg, color = :green, markersize = 10)
f1




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