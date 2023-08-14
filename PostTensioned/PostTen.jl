# module PostTen
using JSON
using HTTP
using Dates

include("pixelgeo.jl") #generating Pixel geometries
include("sectionproperties.jl")
include("calstr.jl") #calculating strength





#HTTP connection
function main()
    #initialize the server
    # try
        server = WebSockets.listen!("127.0.0.1", 2000) do ws
            for msg in ws
                println("Hello World")
                today = string(Dates.today())
                today = replace(today, "-" => "_")
                filename = today*".json"
                data = JSON.parse(msg, dicttype=Dict{String,Float64})

                open(joinpath(@__DIR__, "input_"*filename), "w") do f
                    write(f, msg)
                end
                println("input_"*filename*" written succesfully")
            
                #work here
                Pu = data["Pu"]
                Mu = data["Mu"]
                Vu = data["Vu"]
                L = data["L"]
                t = data["t"]
                Lc = data["Lc"]

                



        
                

                #output
                #Dummies
                fc′ = [28.0, 28.0, 35.5, 58.0]
                as = [99.0, 140.0, 99.0, 140.0]
                ec = [0.5, 0.65, 0.90, 0.77 ]
                fpe = [186.0, 200.0, 354.0, 400.0]
                
                n = length(fc′)
                outr = Vector{Dict{String,Float64}}(undef, n)
                for i = 1:n
                    outr[i] = Dict("fc_prime" => fc′[i], "as" => as[i], "ec" => ec[i], "fpe" => fpe[i])
                end    
                
      
                jsonfile = JSON.json(outr)
                HTTP.send(ws,jsonfile)
                open(joinpath(@__DIR__,"output_"*filename), "w") do f
                    write(f, jsonfile)
                    println("output_"*filename*" written succesfully")

                end
            end
        end
    # catch 
    #     println("Error")
    #     println("Closing the server")
    #     WebSockets.close(server)
    #     return server
    # end
end


server = main()
close(server)


#close(server)
 


#get the data
filename = PostTen.initialize()

file = open(joinpath(@__DIR__,filename) )
data = JSON.parse(file)
#data is a dictionary with keys
section : {L , t, Lc}
ec_max
demands : {Mu, Vu, Pu}

###
#a function that input L, t,Lc and get area, inertia and cg out.

#save the csv file.

#from now on, read the file.

CSVfilename = "pixel_$L_$t_$Lc.csv"
# a function that read and interpolate points between files.

#calculation results 
ac = 400.0 #total cross section area of the section


#constant parameters
Ep = 200_000

#loops
#full
"""
dx = dy = 0.25
n for pixel = 10
"""
function test1()
    #  range_fc′ = 28:7:56
    #  range_as = [99.0 , 140.0]
    #  range_ec = 0.5:0.1:ec_max
    #  range_fpe = (0.1:0.1:0.7) * 1860.0
#test
range_fc′ = 28
range_as = 99.0
range_ec = 0.5
range_fpe = 186.0


total_s = length(range_fc′) * length(range_as) * length(range_ec) * length(range_fpe)
results = Matrix{Float64}(undef,4, total_s)
     #we will loop through these three parameters and get the results.
# with constant cross section properties.
for idx_fc′ in eachindex(range_fc′)
    for idx_as in eachindex(range_as)
        for idx_ec in eachindex(range_ec)
            for idx_fpe in eachindex(range_fpe)
                global fc′ = range_fc′[idx_fc′]
                global as = range_as[idx_as]
                global ec = range_ec[idx_ec]
                global fpe = range_fpe[idx_fpe]


                pu, mu, vu, valid = calstr()
                idx = map(idx_fc′ , idx_as, idx_ec, idx_fpe)


            end
        end
    end
end
end
#Calculation starts here.

    #Pure Compression Capacity
    ccn = 0.85 * fc′ * ac
    #need a justification on 0.003 Ep
    pn = (ccn - (fpe - 0.003 * Ep) * as) / 1000 #[kN]
    pu = 0.65 * 0.8 * pn #[kN]
    ptforce = pu #[kN]
    # @printf "The pure compression capacity is %.3f [kN]\n" pu
    # println("#"^50)

    #Pure Moment Capacity

    #From ACI318M-19 Table: 20.3.2.4.1
    ρ = as / ac #reinforcement ratio (Asteel/Aconcrete)
    fps1 = fpe + 70 + fc′ / (100 * ρ) #
    fps2 = fpe + 420
    fps3 = 1300.0 #Yield str of steel from ASTM A421
    fps = minimum([fps1, fps2, fps3])

    #concrete compression area balanced with steel tension force.
    acomp = as * fps / (0.85 * fc′)
    #get the depth of the compression area, in the form of y coordinate.
    depth, chk = getdepth(pixelpts, acomp, [ytop, ybot])

    #set of points that represent the compression area.
    ptscomp = pixelpts[chk, :]

    #calculate the moment arm.
    #get cgy of the compression area.
    ~, cgcomp = secprop(ptscomp, 0.0)
    #moment arm of the section is the distance between the centroid of the compression area and the steel.
    arm = cgcomp - steelpos
    mn_steel = as * fps * arm / 1e6 #[kNm]

    #Recheck with concrete.
    #check compression strain, make sure it's not more than 0.003
    c = depth
    ϵs = fps / Ep
    ϵc = c * ϵs / (ds - c)

    if ϵc > 0.003
        println("Compression strain is more than 0.003")
        println("Please rework with the section")
    end


    mu = Φ(ϵs) * mn_steel #[kNmm]

    # @printf "The pure moment capacity is %.3f [kNm]\n" mu
    # println("#"^50)




    #Shear Calculation
    ashear = ac * shear_ratio
    fctk = ftension
    ρs = as / ashear
    k = clamp(sqrt(200.0 / d), 0, 2.0)
    fFts = 0.45 * fR1
    wu = 1.5
    CMOD3 = 1.5
    ned = ptforce# can be different
    σcp1 = ned / ac
    σcp2 = 0.2 * fc′
    σcp = clamp(σcp1, 0.0, σcp2)
    fFtu = get_fFtu(fFts, wu, CMOD3, fR1, fR3)
    vn = ashear * get_v(ρs, fc′, fctk, fFtu, 1.0, σcp1, k)#kN
    vu = 0.75 * vn

    # println("#"^50)
    # @printf "The shear capacity is %.3f [kN]\n" vu





