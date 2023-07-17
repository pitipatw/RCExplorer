module NewPixelExam

#define packages that will be used
using Makie, GLMakie
using StatsBase

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
    println(d)
    b_w = 12.0 #in #web width, diameter of circular section
    beam_span_length = 28.0 #ft
    h_f = 6.0 #in
    spacing_between_beams = 12.0 #ft
    fc′ = 4000.0 #psi


    #creating a dictionary for two same size bars combinations'areas
    two_bars_area = Dict("No.3" => 0.22, "No.4" => 0.4, "No.5" => 0.62,
        "No.6" => 0.88, "No.7" => 1.2, "No.8" => 1.58, "No.9" => 2,
        "No.10" => 2.54, "No.11" => 3.12, "No.14" => 4.5, "No.18" => 8)

    #creating a dictionary for bar size and their radius
    bars_radius = Dict("No.3" => 0.1875, "No.4" => 0.25, "No.5" => 0.3125,
        "No.6" => 0.375, "No.7" => 0.4375, "No.8" => 0.5, "No.9" => 0.564,
        "No.10" => 0.635, "No.11" => 0.705, "No.14" => 0.8465, "No.18" => 1.1285)


    #creating an array to store points to plot


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

    println(b)

    a = a(A_s, f_y, fc′, b)
    println("a= ", a)
end

end # module NewPixelExam

NewPixelExam.main()