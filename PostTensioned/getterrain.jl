using Dates

include("pixelgeo.jl")
include("sectionproperties.jl")
include("ptFunc.jl")



# range_fc′ = 28.:7.:56.
# range_as = [99.0, 140.0]
# ec_max = 0.7
# range_ec = 0.5:0.1:ec_max
# range_fpe = (0.1:0.1:0.7) * 1860.0


#old version
# function map(idx_fc′, idx_as, idx_ec, idx_fpe;
#     range_fc′=range_fc′, range_as=range_as, range_ec=range_ec, range_fpe=range_fpe)
#     return idx_fpe +
#            length(range_fpe) * (idx_ec - 1) +
#            length(range_fpe) * length(range_ec) * (idx_as - 1) +
#            length(range_fpe) * length(range_ec) * length(range_as) * (idx_fc′ - 1)
# end
function map(n::Vector{Int64}, idx::Vector{Int64})
    d = Vector{Int64}(undef, length(n))
    for i in eachindex(n) 
        if i == length(d)
            d[i] = mod(idx[i]+n[i]-1, n[i])+1
        else
            d[i] = (idx[i]-1)*prod(n[i+1:end])
        end
    end
    return sum(d)
end


function fc2e(fc′::Real)
    out = -0.0626944435544512 * fc′^2 + 10.0086510099949 * fc′ + 84.14807
   return  out
end


function calcap(fc′, as, ec, fpe;
    L = 102.5,
    t = 17.5,
    Lc = 15.,
    # L = 402.5,
    # t = 17.5,
    # Lc = 15.,
    Ep = 200_000,
    shear_ratio = 0.30,
    fR1 = 2.0,
    fR3 = 2.0 * 0.850)
    #Calculation starts here.

    #load section properties file
    # filename = "pixel_$L_$t_$Lc.csv"
    # section = CSV.read(filename, header=true)
    d = 1.5*L

    
    ac = getprop(0.0,L,t,Lc) #get from the sectin properties


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
    steelpos = ec*-L
    if acomp > ac 
        println("Acomp exceeds Ac, using Ac instead")
        acomp = ac
    end
    depth, cgcomp= getprop(acomp, L, t, Lc)
    # mn_steel = as * fps * arm / 1e6 #[kNm]

    #Recheck with concrete.
    #check compression strain, make sure it's not more than 0.003
    c = depth
    ϵs = fps / Ep
    ϵc = c * ϵs / (steelpos - c)

    if ϵc > 0.003
        # println("Compression strain is $ϵc which is more than 0.003")
        #recalc based on the compression strain
        #calculate the new compression area based on the strain
        #first find depth based on the 0.003 strain at the top

        ϵc_new = 0.003
        depth = L #first guess
        tol = 0.001

        while tol > 0.001
            ϵs_new = ϵc_new*(steelpos - depth) / depth
            fps_new = ϵs_new * Ep

            @show acomp = as * fps_new / (0.85 * fc′)
    
            depth_new, cgcomp= getprop(acomp, L, t, Lc)
            tol = abs(depth_new - depth)/depth
            depth = depth_new
        end
    end

    arm = cgcomp - steelpos
        #moment arm of the section is the distance between the centroid of the compression area and the steel.

    mn = 0.85 * fc′ * ac * arm / 1e6 #[kNm]
    mu = Φ(ϵs) * mn #[kNmm]

    # @printf "The pure moment capacity is %.3f [kNm]\n" mu
    # println("#"^50)




    #Shear Calculation

    ashear = ac * shear_ratio
    fctk = 0.17*sqrt(fc′)
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




    #Embodied Carbon Calculation
    cfc = fc2e(fc′)
    # 0.854 #kgper kg
    # 7850 kg/m3
    cst = 0.854*7850 #kgCO2e/m3

    embodied = ( ac * cfc + as * cst )/ 1e6


#write output into CSV
# dataall = hcat(val,res,checkres)
# table1 = DataFrame(dataall, :auto)
# CSV.write("output.csv", table1)

#parallel plot the result 

#Scatter plot the result.
    return pu, mu, vu, embodied
end

function getterrain(; test=true)
    if !test
        range_fc′ = 28.:7.:56.
        range_as = [99.0, 140.0]
        range_ec = 0.5:0.1:1.2
        range_fpe = (0.00:0.02:0.3) * 1860.0
    else
        #test
        range_fc′ = 28.
        range_as = 99.0
        range_ec = 0.5
        range_fpe = 186.0
    end

    nfc′ = length(range_fc′)
    nas = length(range_as)
    nec = length(range_ec)
    nfpe = length(range_fpe)


    total_s = nfc′ * nas * nec * nfpe
    results = Matrix{Float64}(undef, total_s, 8)
    #we will loop through these three parameters and get the results.
    # with constant cross section properties.
    n = [nfc′, nas, nec, nfpe]
    for idx_fc′ in eachindex(range_fc′)
        for idx_as in eachindex(range_as)
            for idx_ec in eachindex(range_ec)
                for idx_fpe in eachindex(range_fpe)
                    fc′ = range_fc′[idx_fc′]
                    as = range_as[idx_as]
                    ec = range_ec[idx_ec]
                    fpe = range_fpe[idx_fpe]

                    pu, mu, vu, embodied = calcap(fc′, as, ec, fpe)
                    idx_all = [idx_fc′, idx_as, idx_ec, idx_fpe]

                    idx = map(n,idx_all)
                    results[idx,:] = [fc′, as, ec, fpe, pu, mu, vu, embodied]


                end
            end
        end
    end

    return results
end

results = getterrain(test=false)
date = Dates.today()
time = Dates.now()
CSV.write("results//output_$date.csv", DataFrame(results, :auto))


# calcap(28., 99.0, 0.5, 1600.0)