using Printf

function calstr()
    #Pure Compression Capacity
    ccn = 0.85 * fc′ * ac
    #need a justification on 0.003 Ep
    pn = (ccn - (fpe - 0.003 * Ep) * as) / 1000 #[kN]
    pu = 0.65 * 0.8 * pn #[kN]
    ptforce = pu #[kN]
    @printf "The pure compression capacity is %.3f [kN]\n" pu
    println("#"^50)

    ##############################

    #Pure Moment Capacity

    #From ACI318M-19 Table: 20.3.2.4.1
    ρ = as / ac #reinforcement ratio (Asteel/Aconcrete)
    fps1 = fpe + 70 + fc′ / (100 * ρ) #
    fps2 = fpe + 420
    fps3 = 1300.0 #Yield str of steel from ASTM A421
    fps = minimum([fps1, fps2, fps3])

    #concrete compression area balanced with steel tension force.
    acomp = as * fps / (0.85 * fc′)

    #need mod here
    #get the depth of the compression area, in the form of y coordinate.
    depth, chk = #getdepth(pixelpts, acomp, [ytop, ybot])

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
        valid = false

    else
        valid = true
    end


    mu = Φ(ϵs) * mn_steel #[kNmm]

    # @printf "The pure moment capacity is %.3f [kNm]\n" mu
    # println("#"^50)

    #Shear Calculation
vu = 0.0

    # ashear = ac * shear_ratio
    # fctk = ftension
    # ρs = as / ashear
    # k = clamp(sqrt(200.0 / d), 0, 2.0)
    # fFts = 0.45 * fR1
    # wu = 1.5
    # CMOD3 = 1.5
    # ned = ptforce# can be different
    # σcp1 = ned / ac
    # σcp2 = 0.2 * fc′
    # σcp = clamp(σcp1, 0.0, σcp2)
    # fFtu = get_fFtu(fFts, wu, CMOD3, fR1, fR3)
    # vn = ashear * get_v(ρs, fc′, fctk, fFtu, 1.0, σcp1, k)#kN
    # vu = 0.75 * vn

    # println("#"^50)
    # @printf "The shear capacity is %.3f [kN]\n" vu


    return pu, mu, vu, valid
end