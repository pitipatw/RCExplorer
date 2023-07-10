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
    fc′ = 4000.0 #psi
    bottom_width = 12.0 #in

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
    function find_A_s(M_u::Float64, ϕ::Float64, f_y::Float64, d::Float64, a::Float64)
        return M_u / (ϕ * f_y * (d - (a / 2)))
    end
    """
    5-16 Rc textbook equation but with different variables
    """
    function find_A_s(; M_u::Float64, ϕ::Float64, f_y::Float64, j::Float64, d::Float64)
        return M_u / (ϕ * f_y * (j * d))
    end
    """
    Equation to determine the depth of the compression stress block, a
    This equation can be used to find A_s in 5-16
    """
    function find_a(A_s, f_y, fc′, b)
        return (A_s * f_y) / (0.85 * fc′ * b)
    end

    """
    Equation for minimum A_s
    """
    function find_A_smin(fc′::Float64, b_w::Float64, d::Float64, f_y::Float64)
        return (3 * sqrt(fc′) * b_w * d) / f_y
    end

    #execution
    A_s = find_A_s(M_u=convert_ft_to_in(M_u),
        ϕ=ϕ, f_y=f_y, j=j, d=d)

    A_smin = find_A_smin(fc′, b_w, d, f_y)

    println(A_s)
    println(A_smin)

    # first checkin point
    if A_smin < A_s
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

    #find a using the smallest b
    a = find_a(A_s, f_y, fc′, b)
    println("a= ", a)

    # find the better A_s value to find the bars size combination
    better_A_s_value = convert_ft_to_in(M_u) / (ϕ * f_y * (d - (a / 2)))

    #interpolation to find the best possible bars combo
    #or should I do this manually???


    #Calculating the spacing limit once the number of bar and size are decided

    # First define initial values after the bars have been selected
    number_of_bars = 2
    side_to_bar_center_dist = 2.5 #in
    f_s = 40000 #psi
    β1 = 0.85 #this is for the concrete compressive strength fc′ of 4000 psi
    c_c = 2 #in
    #this new A_s is due to the combination of bar selected, in this case, 2 No.8 bars
    A_s_final = 1.58 #in

    # write the spacing limit function
    s1 = 15 * (40000 / f_s) - (2.5 * c_c)
    s2 = 12 * (40000 / f_s)

    s = min(s1, s2)

    println("s1 = ", s1)
    println("s2 = ", s2)
    println(s)

    actual_s = bottom_width - (number_of_bars * side_to_bar_center_dist)

    if actual_s < s
        println(true)
    else
        println(false)
    end

    # if the code passes both check points, proceed to this required strength check
    a_final = find_a(A_s_final, f_y, fc′, b)

    c = a_final / β1
    println("c = ", c)

    # checkpoint 3
    # check if c is less than 3/8 of d, to ensure this is a tension-controlled section

    if c < (3 * d) / 8
        println(true)
    else
        println(false)
    end

    # check again to see if jd(d-a/2) is larger than asuumed value
    # which is 0.95d in this case and how much percent larger
    final_jd = d - (a_final / 2)
    initial_jd = 0.95 * d
    percent_larger_btwn_final_and_initial_jd = 100 * (final_jd - initial_jd) / abs(initial_jd)

    println("Final jd is larger than initial assumption by ", percent_larger_btwn_final_and_initial_jd, "%")

    #final final check
    M_n = A_s_final * f_y * (final_jd)

    if ϕ * M_n >= M_u
        println(true)
    else
        println(false)
    end



end

end # module NewPixelExam

NewPixelExam.main()