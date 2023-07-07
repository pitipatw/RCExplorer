module NewPixelExam

#define packages that will be used
using Makie, GLMakie

function main()
    # initial known values
    M_u = 130000.0 #ft
    ϕ = 0.9 #no unit
    f_y = 60000.0 #psi
    j = 0.95 # assumption
    d = 21.5 #in
    b_w = 12.0 #in
    beam_span_length = 28.0 #ft
    h_f = 6.0 #in
    spacing_between_beams = 12.0 #ft

    #setting up equations
    """
    Change ft to inches
    """
    function convert_ft_to_in(ft)
        return ft * 12
    end

    """
    Equation for determining the required steel area in a singly reinforced section
    5-16 RC textbook
    """
    function A_s(M_u::Float64, ϕ::Float64, f_y::Float64, d::Float64, a::Float64)
        return M_u / (ϕ * f_y * (d - (a / 2)))
    end
    """
    5-16 Rc textbook equation but with different variables
    """
    function A_s(; M_u::Float64, ϕ::Float64, f_y::Float64, j::Float64, d::Float64)
        return M_u / (ϕ * f_y * (j * d))
    end
    """
    Equation to determine the depth of the compression stress block, a
    This equation can be used to find A_s in 5-16
    """
    function a(A_s, f_y, fc′, b)
        return (A_s * f_y) / (0.85 * fc′ * b)
    end

    """
    Equation for minimum A_s
    """
    function A_smin(b_w::Float64, d::Float64, f_y::Float64)
        return (200.0 * b_w * d) / f_y
    end

    #execution
    A_s = A_s(M_u=convert_ft_to_in(M_u),
        ϕ=ϕ, f_y=f_y, j=j, d=d)

    Asmin = A_smin(b_w, d, f_y)

    println(A_s)
    println(Asmin)

    if Asmin < A_s
        println(true)
    else
        println(false)
    end


    # Section 4-8 of RC textbook, ACI 8.12.2
    # limits for the effective width of the compression flange
    effective_width_b1 = convert_ft_to_in(beam_span_length) / 4
    effective_width_b2 = b_w + (2 * 8 * h_f)
    effective_width_b3 = (convert_ft_to_in(spacing_between_beams))

    b = min(effective_width_b1, effective_width_b2, effective_width_b3)

    println("bₑ1 = ", effective_width_b1)
    println("bₑ2 = ", effective_width_b2)
    println("bₑ3 = ", effective_width_b3)
    println(b)

    a = a(A_s, f_y, fc′, b)
    println("a= ", a)
end

end # module NewPixelExam

NewPixelExam.main()