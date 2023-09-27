function dummies()
    fc′ = [28.0, 28.0, 35.5, 58.0]
    as = [99.0, 140.0, 99.0, 140.0]
    ec = [0.5, 0.65, 0.90, 0.77 ]
    fpe = [186.0, 200.0, 354.0, 400.0]
    pu = [100.0, 200.0 , 250.0, 300.0]
    mu = [20.0 , 500., 1000.0, 1500.0]
    vu = [10.0, 100.0, 200.0, 300.0]

    n = length(fc′)
    outr1 = Vector{Dict{String,Float64}}(undef, n)
    outr2 = Matrix{Float64}(undef, n, 7)
    for i = 1:n
        outr1[i] = Dict("fc_prime" => fc′[i], "as" => as[i], "ec" => ec[i], "fpe" => fpe[i], "pu" => pu[i], "mu" => mu[i], "vu" => vu[i])
        outr2[i,:] = [fc′[i], as[i], ec[i], fpe[i], pu[i], mu[i], vu[i]]
    end    
    return outr1, outr2
end


function dummies2()
    fc′ = [59.0, 35.0, ]
    as = [99.0, 140.0, ]
    ec = [0.5, 0.65, ]
    fpe = [186.0, 200.0,]
    pu = [100.0, 200.0 , ]
    mu = [20.0 , 500., ]
    vu = [10.0, 100.0, ]

    
    n = length(fc′)
    outr = Vector{Dict{String,Float64}}(undef, n)
    for i = 1:n
        outr[i] = Dict("fc_prime" => fc′[i], "as" => as[i], "ec" => ec[i], "fpe" => fpe[i], "pu" => pu[i], "mu" => mu[i], "vu" => vu[i])
    end    
    return outr
end
