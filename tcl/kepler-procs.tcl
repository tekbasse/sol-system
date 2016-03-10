#/sol-system/tcl/kepler-procs.tcl
# based on publication "Keplerian Elements for Approimate Positions of the Major Planets"
#   by E M Standish, Solar System Dyamics Group, JPL/Caltech
#   retrieved from http://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf on 27 Feb 2016
#

namespace eval ssk {

    variable planets_list [list Mercury Venus EM-Bary Mars Jupiter Saturn Uranus Neptune Pluto]
    # EM-Bary = Earth-Moon Barycenter

    # constant used in trig functions, 180degrees per pi radians
    #set 180perpi \[expr { 180. / ( 2. * acos(0.) ) } \]
    variable 180perpi 57.29577951308232
    variable icrf1_epsilon_deg 23.43928
    # Table Data PDF to txt work already available by Sonia Keys (Cambridge Mass) 
    # via public domain work in aprx.go file
    #   retrieved from https://github.com/soniakeys/aprx.git on 28 Feb 2016
    # The following "//" comments in comments are Sonia Keys'
    #
    #	// data copied from Table 1, file p_elem_t1.txt.  A table of Go numeric
    #	// literals would be convenient, but data is copied as a single large
    #	// string to avoid typographical errors.
    #	//         a              e               I                L            long.peri.      long.node.
    #	//     AU, AU/Cy     rad, rad/Cy     deg, deg/Cy      deg, deg/Cy      deg, deg/Cy     deg, deg/Cy
    # file url: http://ssd.jpl.nasa.gov/txt/p_elem_t1.txt

    # data loaded directly as an array of planets, where each tableN(planet) returns an ordered list
    variable table1_larr
    set table1_larr(Mercury) [list \
                             0.38709927      0.20563593      7.00497902      252.25032350     77.45779628     48.33076593 \
                             0.00000037      0.00001906     -0.00594749   149472.67411175      0.16047689     -0.12534081 ]
    set table1_larr(Venus) [list \
                           0.72333566      0.00677672      3.39467605      181.97909950    131.60246718     76.67984255 \
                           0.00000390     -0.00004107     -0.00078890    58517.81538729      0.00268329     -0.27769418 ]
    set table1_larr(EM-Bary) [list \
                             1.00000261      0.01671123     -0.00001531      100.46457166    102.93768193      0.0 \
                             0.00000562     -0.00004392     -0.01294668    35999.37244981      0.32327364      0.0 ]
    set table1_larr(Mars) [list \
                          1.52371034      0.09339410      1.84969142       -4.55343205    -23.94362959     49.55953891 \
                          0.00001847      0.00007882     -0.00813131    19140.30268499      0.44441088     -0.29257343 ]
    set table1_larr(Jupiter) [list \
                             5.20288700      0.04838624      1.30439695       34.39644051     14.72847983    100.47390909 \
                             -0.00011607     -0.00013253     -0.00183714     3034.74612775      0.21252668      0.20469106 ]
    set table1_larr(Saturn) [list \
                            9.53667594      0.05386179      2.48599187       49.95424423     92.59887831    113.66242448 \
                            -0.00125060     -0.00050991      0.00193609     1222.49362201     -0.41897216     -0.28867794 ]
    set table1_larr(Uranus) [list \
                            19.18916464      0.04725744      0.77263783      313.23810451    170.95427630     74.01692503 \
                            -0.00196176     -0.00004397     -0.00242939      428.48202785      0.40805281      0.04240589 ]
    set table1_larr(Neptune) [list \
                             30.06992276      0.00859048      1.77004347      -55.12002969     44.96476227    131.78422574 \
                             0.00026291      0.00005105      0.00035372      218.45945325     -0.32241464     -0.00508664 ]
    set table1_larr(Pluto) [list \
                           39.48211675      0.24882730     17.14001206      238.92903833    224.06891629    110.30393684 \
                           -0.00031596      0.00005170      0.00004818      145.20780515     -0.04062942     -0.01183482 ]

    #    // data copied from Table 2a, p_elem_t2.txt
    #    //         a              e               I                L            long.peri.      long.node.
    #    //     AU, AU/Cy     rad, rad/Cy     deg, deg/Cy      deg, deg/Cy      deg, deg/Cy     deg, deg/Cy
    #  file url: http://ssd.jpl.nasa.gov/txt/p_elem_t2.txt
    variable table2a_larr
    set table2a_larr(Mercury) [list \
                              0.38709843      0.20563661      7.00559432      252.25166724     77.45771895     48.33961819 \
                              0.00000000      0.00002123     -0.00590158   149472.67486623      0.15940013     -0.12214182 ]
    set table2a_larr(Venus) [list \
                            0.72332102      0.00676399      3.39777545      181.97970850    131.76755713     76.67261496 \
                            -0.00000026     -0.00005107      0.00043494    58517.81560260      0.05679648     -0.27274174 ] 
    set table2a_larr(EM-Bary) [list \
                              1.00000018      0.01673163     -0.00054346      100.46691572    102.93005885     -5.11260389 \
                              -0.00000003     -0.00003661     -0.01337178    35999.37306329      0.31795260     -0.24123856 ]
    set table2a_larr(Mars) [list \
                           1.52371243      0.09336511      1.85181869       -4.56813164    -23.91744784     49.71320984 \
                           0.00000097      0.00009149     -0.00724757    19140.29934243      0.45223625     -0.26852431 ]
    set table2a_larr(Jupiter) [list \
                              5.20248019      0.04853590      1.29861416       34.33479152     14.27495244    100.29282654 \
                              -0.00002864      0.00018026     -0.00322699     3034.90371757      0.18199196      0.13024619 ]
    set table2a_larr(Saturn) [list \
                             9.54149883      0.05550825      2.49424102       50.07571329     92.86136063    113.63998702 \
                             -0.00003065     -0.00032044      0.00451969     1222.11494724      0.54179478     -0.25015002 ]
    set table2a_larr(Uranus) [list \
                             19.18797948      0.04685740      0.77298127      314.20276625    172.43404441     73.96250215 \
                             -0.00020455     -0.00001550     -0.00180155      428.49512595      0.09266985      0.05739699 ]
    set table2a_larr(Neptune) [list \
                              30.06952752      0.00895439      1.77005520      304.22289287     46.68158724    131.78635853 \
                              0.00006447      0.00000818      0.00022400      218.46515314      0.01009938     -0.00606302 ]
    set table2a_larr(Pluto) [list \
                            39.48686035      0.24885238     17.14104260      238.96535011    224.09702598    110.30167986 \
                            0.00449751      0.00006016      0.00000501      145.18042903     -0.00968827     -0.00809981 ]

    #    // data copied from Table 2b, p_elem_t2.txt
    #    //                           b             c             s            f

    # for simplicity in coding, adding blank values for planets not in original table2b
    variable table2b_larr
    set table2b_larr(Mercury) [list ]
    set table2b_larr(Venus) [list ]
    set table2b_larr(EM-Bary) [list ]
    set table2b_larr(Mars) [list ]
    set table2b_larr(Jupiter) [list   -0.00012452    0.06064060   -0.35635438   38.35125000 ]
    set table2b_larr(Saturn) [list     0.00025899   -0.13434469    0.87320147   38.35125000 ]
    set table2b_larr(Uranus) [list     0.00058331   -0.97731848    0.17689245    7.67025000 ]
    set table2b_larr(Neptune) [list   -0.00041348    0.68346318   -0.10162547    7.67025000 ]
    # only one reference for Pluto, by using lindex, other references will be empty, just as in cases of Mercury through Mars.
    set table2b_larr(Pluto) [list     -0.01262724 ]

}

ad_proc -public ssk::days_since_j2000 {
    yyyymmdd
} {
    Returns decimal days since j2000, where yyyymmdd is in format "20160102" for Jan. 2, 2016. 
    A negative number means days before j2000.
    Time can be optionally appended to yyyymmdd, such as "20160102 11:05 AM".
} {
    # per https://en.wikipedia.org/wiki/Epoch_(reference_date)#J2000.0
    # j2000.0
    #  = Gregorian date 1, 2000 cira 12:00GMT
    #  = Julian date 2451545.0 TT (Terrestrial Time)
    #  = January 1, 2000 11:59:27.816 International Atomic Time
    #  = January 1, 2000 11:58:55.816 UTC (Coordinated Universal time)
    # see also https://en.wikipedia.org/wiki/Epoch_(astronomy)#Julian_years_and_J2000
    # Julian epoch = 2000.0 = ( Julian date - 2451545.0 ) / 365.25

    #// Julian dates corresponding to years
    #
    #set	j3000b 625673.5
    #set	j1800  2378496.5
    # j2000 = 2451545.0
    #set	j2000  2451545.0
    #set	j2050  2469807.5
    #set	j3000  2816787.5
    # Returning value $delta_days is about half a day different for j2050, j3000, j1800, if time standard is not included.
    # So, including time standard in s1. Theoretically, s2 could include time also.

    set s1 [clock scan "20000101 12:00"]
    set s2 [clock scan $yyyymmdd ]
    #set day_in_secs \[expr { 24 * 60 * 60 } \]
    set day_in_secs 86400.0
    set delta_days [expr { ( $s2 - $s1 ) / $day_in_secs } ]
    return $delta_days
}

ad_proc -public ssk::in_j2000 {
    yyyymmdd
} {
    Returns decimal days in j2000.
    Time can be optionally appended to yyyymmdd, such as "20160102 11:05 AM".
} {
    # Based on days_since_j2000
    # adding standard value of j2000
    set s1 [clock scan "20000101 12:00"]
    set s2 [clock scan $yyyymmdd ]
    #set day_in_secs \[expr { 24 * 60 * 60 } \]
    set day_in_secs 86400.0
    set j2000 2451545.0
    set j2000_days [expr { $j2000 + ( $s2 - $s1 ) / $day_in_secs } ]
    return $j2000_days
}


ad_proc -public ssk::pos_kepler {
    yyyymmdd
    planets
    array_name
    {icrf_p 0}
} {
    Returns position of planet(s). 
    Planets can be one or more of an index number of (0..8), or a direct reference of,  ssk::planets_list ie  Mercury Venus EM-Bary Mars Jupiter Saturn Uranus Neptune Pluto, where EM-Bary refers to Earth-Moon Barycenter.
    Values are returned to array_name, where array_name(planet_ref) contains a list of x, y, and z cartesian values relative to the plane of the ecliptic, x-axis aligned with Earth equinoxes (Vernal positive, Autumnal negative), and with sun at origin and units in Astronomical Units (AU) per Kepler calculations and supplied data; See code for details.
    Set icrf_p to 1 to return coordinates in standardized "ICRF/J2000 frame" where obliquity at J2000 is epsilon = 23.43928 degrees.
} {
    # More about ICRF at: https://en.wikipedia.org/wiki/International_Celestial_Reference_Frame

    upvar 1 array_name temp_larr
    # store values in an array ssk::pos_k_arr(planet,j2000_date) to cache repeat calculations at least within same request.
    variable ::ssk::pos_k_arr
    variable ::ssk::planets_list
    variable ::ssk::table1_larr
    variable ::ssk::table2a_larr
    variable ::ssk::table2b_larr
    variable ::ssk::180perpi
    variable ::ssk::icrf1_epsilon_deg

    set p_list [split $planets ]
    # Major Planets list
    set mp_list [list ]
    foreach p $p_list {
        set p_i -1
        if { [qf_is_natural_number $p] } {
            set p_i [lindex $planets_list $p]
        } else {
            set p_i [lsearch -exact -nocase $planets_list $p]
        }
        if { $p_i > -1 } {
            lappend mp_list $p_i
        }
    }
    # t_cap is number of centuries past J2000.0
    # one J2000 year is 365.25 days
    set t_cap [expr { [ssk::days_since_j2000 $yyyymmdd] / 36525. } ]
    if { $t_cap > -2. && $t_cap < 0.5 } {
        # Use table1 for time range 1800 AD to 2050AD
        set use_table1_p 1
    } else {
        # If not table 1, then table2 will be used.
        # Use table2 is valid for range 3000BC to 3000AD, but best available if
        # table1 is not used, regardless.
        set use_table1_p 0
    }
    foreach mp_i $mp_list {
        set mp [lindex $planets_list $mp_i]

        if { ![info exists pos_k_arr(${mp},${yyyymmdd},0) ] } {
            # 1. Compute the value of planet's six orbital elements
            #

            # alpha       semi-major axis (au, au / century)
            # ecc     eccentricity ( - , - / century )
            # iota_cap    inclination ( degrees, degrees / century )
            # el_cap      mean longitude ( degrees, degrees / century )
            # pi_sym      longitude of perihelion ( degrees , degrees / century )
            # omega_cap   longitude of ascending node ( degrees , degrees / century )

            # note: variable names follow naming from Standish paper.
            # *_cap means letter or variable capitalized (caps)
            # *_sym means letter in symbolic form (different than standard, such as pi_sym)
            # *_star means letter with asterisk suffix.
            # *_(other suffix) is standard tcl for subnotation, such as sub i as in index etc.
            # *_arr indicates variable is an array
            # *_larr indicates variable is an array, where each array value is a list
            if { $use_table1_p } {
                set alpha [expr { [lindex $table1_larr($mp) 0] + $t_cap * [lindex $table1_larr($mp) 1] } ]
                set ecc [expr { [lindex $table1_larr($mp) 2] + $t_cap * [lindex $table1_larr($mp) 3] } ]
                set iota_cap [expr { [lindex $table1_larr($mp) 4] + $t_cap * [lindex $table1_larr($mp) 5] } ]
                set el_cap [expr { [lindex $table1_larr($mp) 6] + $t_cap * [lindex $table1_larr($mp) 7] } ]
                set pi_sym [expr { [lindex $table1_larr($mp) 8] + $t_cap * [lindex $table1_larr($mp) 9] } ]
                set omega_cap [expr { [lindex $table1_larr($mp) 10] + $t_cap * [lindex $table1_larr($mp) 11] } ]
            } else {
                set alpha [expr { [lindex $table2a_larr($mp) 0] + $t_cap * [lindex $table2a_larr($mp) 1] } ]
                set ecc [expr { [lindex $table2a_larr($mp) 2] + $t_cap * [lindex $table2a_larr($mp) 3] } ]
                set iota_cap [expr { [lindex $table2a_larr($mp) 4] + $t_cap * [lindex $table2a_larr($mp) 5] } ]
                set el_cap [expr { [lindex $table2a_larr($mp) 6] + $t_cap * [lindex $table2a_larr($mp) 7] } ]
                set pi_sym [expr { [lindex $table2a_larr($mp) 8] + $t_cap * [lindex $table2a_larr($mp) 9] } ]
                set omega_cap [expr { [lindex $table2a_larr($mp) 10] + $t_cap * [lindex $table2a_larr($mp) 11] } ]
            }

            # 2. Compute argument of perihelion, omega and mean anomaly m_cap, where
            #     omega = pi_sym - omega_cap  
            #
            #     m_cap = el_cap - pi_sym + b*pow(t_cap,2) + c*cos(f*t_cap) + s* sin(f*t_cap)
            #
            set omega [expr { $pi_sym - $omega_cap } ]
            set m_cap [expr { $el_cap - $pi_sym } ]

            if { !$use_table1_p } {
                # add Table2 additional terms, if existing
                # terms from tabl2b
                set b [lindex $table2b_larr($mp) 0]
                set c [lindex $table2b_larr($mp) 1]
                set s [lindex $table2b_larr($mp) 2]
                set f [lindex $table2b_larr($mp) 3]
                if { $b ne "" } {
                    set m_cap [expr { $m_cap + $b * pow( $t_cap , 2.) } ]
                }
                if { $c ne "" && $f ne "" } {
                    # c requres f
                    # cos expects radians, does original equation expect radians or degrees? degrees
                    # Adding conversion via 180perpi
                    set m_cap [expr { $m_cap + $c * cos( $f * $t_cap / $180perpi ) } ]
                }
                if { $s ne "" && $f ne "" } {
                    # s requires f
                    # sin expects radians, does original equation expect radians or degrees? degrees
                    # Adding conversion via 180perpi
                    set m_cap [expr { $m_cap + $s * sin( $f * $t_cap / $180perpi ) } ]
                }
            }

            # 3a. Modulus the mean anomaly (m_cap) to within 180 degrees of 0.
            
            set m_cap [expr { fmod( $m_cap, 180.) } ]
            

            # 3b. Obtain the eccentric anomaly, e_cap from:
            #   Kepler's Equation:
            #     m_cap = e_cap - e_star * sin(e_cap) where e_star = 180*e/pi = 57.29578*e
            # From Standish paper, 
            #   Solution of Kepler's Equation 
            #   Given:
            #   m_cap  is mean anomaly in degrees
            #   e_star is eccentricity in degrees (ie ecc * $180perpi)
            
            # Start with e_cap_0 = m_cap + e_star * sin( m_cap / $180perpi )
            # converting array to scalar for speed
            set m_cap $m_cap
            set e $ecc 
            # Normally, use i for iteration, here using "n" per Standish paper
            set n 0
            set e_cap_n [expr { $m_cap + $e * $180perpi * sin( $m_cap / $180perpi) } ]
            # interation calculations
            # tol is tollerance in degres
            set tol 1e-6
            # Make test fail first time:
            set delta_e_cap [expr { $tol + 1. } ]
            set lc_limit 10000
            while { $delta_e_cap > $tol && $n < $lc_limit } {
                if { $n >= $lc_limit } {
                    ns_log Warning "ssk::pos_kepler interation limit of '${lc_limit}' reached, n '${n}' delta_e_cap '${delta_e_cap}' tol '${tol}'"
                }
                set delta_m_cap [expr { $m_cap - ( $e_cap_n - $e * $180perpi( $e_cap_n / $180perpi ) ) } ]
                set delta_e_cap [expr { $delta_m_cap / ( 1. - $e * cos( $e_cap_n / $180perpi ) ) } ]
                #set n_prev $n
                # c/e_cap_arr($n)/e_cap_n/
                #set e_cap_n_prev $e_cap_n
                # e_cap_n_prev is just used once; in setting new e_cap_n, so 
                # we can simplify by just referring to old e_cap_n when calculating new one
                incr n
                #set e_cap_n\ [expr { $e_cap_n_prev + $delta_e_cap } \]
                set e_cap_n [expr { $e_cap_n + $delta_e_cap } ]
            }
            # eccentric anomoly is e_cap, assign from iteration
            set e_cap $e_cap_n

            # 4. Compute planet's heliocentric coordinates in its orbital plane, r_prime
            #    with x_prime axis aligned from the focus to the perhihelion.
            #    x_prime = a* (co(E) - e) 
            #    y_prime = a* sqrt(1 - pow(e,2)) * sin(e_cap)
            #    z_prime = 0
            set x_prime [expr { $alpha * ( cos( $e_cap / $180perpi ) - $ecc ) } ]
            set y_prime [expr { $alpha * sin( $e_cap / $180perpi ) * sqrt( 1. - pow( $ecc, 2.) ) } ]
            set z_prime 0.

            # 5. Compute coordinates, r_ecliptic in the J2000 ecliptic plane, with 
            #    x-axis aligned toward the equinox:

            set cos_omega [expr { cos( $omega / $180perpi ) } ]
            set sin_omega [expr { sin( $omega / $180perpi ) } ]
            set cos_omega_cap [expr { cos( $omega_cap / $180perpi ) } ]
            set sin_omega_cap [expr { sin( $omega_cap / $180perpi ) } ]
            set cos_iota_cap [expr { cos( $iota_cap / $180perpi ) } ]
            set sin_iota_cap [expr { sin( $iota_cap / $180perpi ) } ]

            # x_ecl = (cos(omega) *cos(omega_cap) - sin(omega)*sin(omega_cap)*cos(iota_cap) ) * x_prime 
            #         + ( -1 * sin(omega)*cos(omega_cap)-cos(omega)*sin(omega_cap)*cos(iota_cap) ) * y_prime
            # y_ecl = (cos(omega) *sin(omega_cap) + sin(omega)*cos(omega_cap)*cos(iota_cap) ) * x_prime 
            #         + ( -1 * sin(omega)*sin(omega_cap)+cos(omega)*cos(omega_cap)*cos(iota_cap) ) * y_prime
            # z_ecl = (sin(omega)*sin(iota_cap)) * x_prime + (cos(omega)*sin(iota_cap) ) * y_prime
            set x_ecl [expr { ( $cos_omega * $cos_omega_cap - $sin_omega * $sin_omega_cap * $cos_iota_cap ) * $x_prime \
                                           + ( -1. * $sin_omega * $cos_omega_cap - $cos_omega * $sin_omega_cap * $cos_iota_cap ) * $y_prime } ]
            set y_ecl [expr { ( $cos_omega * $sin_omega_cap + $sin_omega * $cos_omega_cap * $cos_iota_cap ) * $x_prime \
                                           + ( -1. * $sin_omega * $sin_omega_cap + $cos_omega * $cos_oemga_cap * $cos_iota_cap ) * $y_prime } ]
            set z_ecl [expr { ( $sin_omega * $sin_iota_cap ) * $x_prime \
                                           + ( $cos_omega * $sin_iota_cap ) * $y_prime } ]

            set pos_k_arr(${mp},${yyyymmdd},0) [list $x_ecl $y_ecl $z_ecl]
        } 
        if { $ifrc_p } {
            # see if value already exists.
            if { ![info exists $pos_k_arr(${mp},${yyyymmdd},1) ] } {
                # transform to ICRF/J2000 frame format
                # we can't depend on prior x_ecl,y_ecl,z_ecl, because value may have been previously calculated.
                set ecl_list $pos_k_arr(${mp},${yyyymmdd},0)
                set x_ecl [lindex $ecl_list 0]
                set y_ecl [lindex $ecl_list 1]
                set z_ecl [lindex $ecl_list 2]
                set x_eq $x_ecl
                set cos_epsilon [expr { cos($icrf1_epsilon_deg / $180perpi ) } ]
                set sin_epsilon [expr { sin($icrf1_epsilon_deg / $180perpi ) } ]
                set y_eq [expr { $cos_epsilon * $y_ecl - $sin_epsilon * $z_ecl } ]
                set z_eq [expr { $sin_epsilon * $y_ecl - $cos_epsilon * $z_ecl } ]
                set pos_k_arr(${mp},${yyyymmdd},1) [list $x_eq $y_eq $z_eq]
            }
            set temp_larr(${mp}) $pos_k_arr(${mp},${yyyymmdd},1)
        } else {
            set temp_larr(${mp}) $pos_k_arr(${mp},${yyyymmdd},0)
        }
    }
    return 1
}
