println("Sanity checking
Values from ASCE 7-10
table 4-1
Live load 
    for office use = 2.4 kN/m2
    for Computer use = 4.79 kN/m2
    Corridors = 4.79 kN/m2
***for residential
        Uninhabitable attics without storage 0.48
        Uninhabitable attics with storage 0.96
        Habitable attics and sleeping areas 1.44
        All other areas except stairs 1.92
        Private rooms and corridors serving them 1.92
        Public rooms and corridors serving them 4.79
    roof
        Garden 4.79
        ordinary flat, pitched, and curved roofs 0.96


in general: 1.92 kN/m2 should do the work.
Beware for 4.79 cases, since it's 2.5 times more than 1.92


")

w = 1.2*4 + 1.6*(1.92*6)

L  = 6

w*L^2/8