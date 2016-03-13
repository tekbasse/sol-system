#/sol-system/tcl/kepler-procs.tcl
ad_library {

    Sol System package procedures
    @creation-date 13 Feb 2016
    @cvs-id $Id:
    @Copyright (c) 2016 Benjamin Brink
    @license GNU General Public License 3, see project home or http://www.gnu.org/licenses/gpl-3.0.en.html
    @project home: http://github.com/tekbasse/sol-system
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com

    Temporary comment about git commit comments: http://xkcd.com/1296/
}

# based on publication "Keplerian Elements for Approimate Positions of the Major Planets"
#   by E M Standish, Solar System Dyamics Group, JPL/Caltech
#   retrieved from http://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf on 27 Feb 2016
#
namespace eval ::ssk {}
namespace eval ::ssk {

    variable planets_list
    set planets_list [list Mercury Venus EM-Bary Mars Jupiter Saturn Uranus Neptune Pluto]
    # EM-Bary = Earth-Moon Barycenter

    # constant used in trig functions, 180degrees per pi radians
    #set 180perpi \[expr { 180. / ( 2. * acos(0.) ) } \]
    variable 180perpi 57.29577951308232
    # Epsilon is the obliauity of the ecliptic.
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

    # Code       Math
    # VarName    Variable    Represents
    # ---------  --------    ------------
    # alpha      a           semi-major axis (au, au / century)
    # ecc        e           eccentricity ( - , - / century )
    # iota_cap   &Iota;      inclination ( degrees, degrees / century )
    # el_cap     L           mean longitude ( degrees, degrees / century )
    # pi_sym     &piv;       longitude of perihelion ( degrees , degrees / century )
    # omega_cap  &Omega;     longitude of ascending node ( degrees , degrees / century )
    
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

    set s1 [clock scan "20000101 12:00" -format "%Y%m%d %H:%M" -gmt 1]
    set s2 [clock scan $yyyymmdd -gmt 1]
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
    set s1 [clock scan "20000101 12:00" -format "%Y%m%d %H:%M" -gmt 1]
    set s2 [clock scan $yyyymmdd -gmt 1]
    #set day_in_secs \[expr { 24 * 60 * 60 } \]
    set day_in_secs 86400.0
    set j2000 2451545.0
    set j2000_days [expr { $j2000 + ( $s2 - $s1 ) / $day_in_secs } ]
    return $j2000_days
}

ad_proc -public ssk::j2000_to_utc {
    j2000_time
    {utc_format "%Y-%h-%d %H:%M:%S"}
} {
    For format string, see 'clock format'. 
} {
    set j2000 2451545.0
    set j2000_utc [clock scan "20000101 12:00" -format "%Y%m%d %H:%M" -gmt 1]
    # covert days to seconds, 24 h/day * 60min/hr * 60s/min = 86400
    set delta_j2000_s [expr { ($j2000_time - $j2000 ) * 86400. } ]
    set time_utc_s [expr { round( $j2000_utc + $delta_j2000_s ) } ]
    set time_utc [clock format $time_utc_s -format $utc_format -gmt 1]
    return $time_utc
}

ad_proc -public ssk::pos_kepler {
    yyyymmdd
    planets
    array_name
    {icrf_p 0}
} {
    Returns position of planet(s).
    If yyyymmdd is a decimal number with a prefix of "J", then value is assumed to be j2000 number.
    Planets can be one or more of an index number of (0..8), or a direct reference of,  ssk::planets_list ie  Mercury Venus EM-Bary Mars Jupiter Saturn Uranus Neptune Pluto, where EM-Bary refers to Earth-Moon Barycenter.
    Values are returned to array_name, where array_name(planet_ref) contains a list of x, y, and z cartesian values relative to the plane of the ecliptic, x-axis aligned with Earth equinoxes (Vernal positive, Autumnal negative), and with sun at origin and units in Astronomical Units (AU) per Kepler calculations and supplied data; See code for details.
    Set icrf_p to 1 to return coordinates in standardized "ICRF/J2000 frame" where obliquity at J2000 is epsilon = 23.43928 degrees.
} {
    # More about ICRF at: https://en.wikipedia.org/wiki/International_Celestial_Reference_Frame

    upvar 1 $array_name temp_larr
    # store values in an array ssk::pos_k_arr(planet,j2000_date) to cache repeat calculations at least within same request.
    variable ::ssk::pos_k_arr
    variable ::ssk::planets_list
    variable ::ssk::table1_larr
    variable ::ssk::table2a_larr
    variable ::ssk::table2b_larr
    variable ::ssk::180perpi
    variable ::ssk::icrf1_epsilon_deg
    set j2000 2451545.0
    set cache_accuracy_s 100
    # validate
    set success_p 1
    set p_list [split $planets ]
    # Major Planets list
    set mp_list [list ]
    foreach p $p_list {
        set p_i -1
        if { [qf_is_natural_number $p] && [lindex $planets_list $p] ne "" } {
            set p_i $p
        } else {
            set p_i [lsearch -exact -nocase $planets_list $p]
        }
        if { $p_i > -1 } {
            lappend mp_list $p_i
        }
    }
    #ns_log Notice "ssk::pos_kepler(230): yyyymmdd '${yyyymmdd}'"
    if { [string match -nocase "j*" [string range $yyyymmdd 0 0]] } {
        set numeric_q [string range $yyyymmdd 1 end]
        #ns_log Notice "ssk::pos_kepler(232): numeric_q $numeric_q"
        if { [qf_is_decimal $numeric_q ] } {
            set t_cap [expr { ( $numeric_q - $j2000 ) / 36525. } ]
            set yyyymmdd [ssk::j2000_to_utc $numeric_q]
            set time_s [clock scan $yyyymmdd -format "%Y-%h-%d %H:%M:%S" -gmt 1]
        } else {
            set success_p 0
        }
    } elseif { [string length $yyyymmdd] == 10 && [string range $yyyymmdd 4 4] eq "-" } {
        # must be in yyyy-mm-dd format, concatinate
        set yyyymmdd "[string range $yyyymmdd 0 3][string range $yyyymmdd 5 6][string range $yyyymmdd 8 9]"
        set t_cap [expr { [ssk::days_since_j2000 $yyyymmdd] / 36525. } ]
        set time_s [clock scan $yyyymmdd -format "%Y%m%d" -gmt 1]
    } elseif { [string length $yyyymmdd] == 8 } {
        set t_cap [expr { [ssk::days_since_j2000 $yyyymmdd] / 36525. } ]
        set time_s [clock scan $yyyymmdd -format "%Y%m%d" -gmt 1]
    } else {
        set success_p 0
    }

    set test_ymd [string range $yyyymmdd 0 7]
    set Debug 0
    if { $test_ymd eq "20160104" || $test_ymd eq "20160105" || $test_ymd eq "20160704" || $test_ymd eq "20160705" } {
        # log some diagnostic info as z switches signs between these days.
        set Debug 1
    } 


    if { $success_p } {
        # validated input
        # t_cap is number of centuries past J2000.0
        # one J2000 year is 365.25 days
        set t_cache [expr { $cache_accuracy_s * round( $time_s / $cache_accuracy_s ) } ]
        
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

            # for diagnostics don't use cache
            if { ![info exists pos_k_arr(${mp},${t_cache},0) ] || 1 } {
                # 1. Compute the value of planet's six orbital elements for indicated century
                #

                # Code        Math
                # VarName     Variable    Represents
                # ---------   --------    ------------
                # alpha       a           semi-major axis (au, au / century)
                # ecc         e           eccentricity ( - , - / century )
                # iota_cap    &Iota;      inclination ( degrees, degrees / century )
                # el_cap      L           mean longitude ( degrees, degrees / century )
                # pi_sym      &piv;       longitude of perihelion ( degrees , degrees / century )
                # omega_cap   &Omega;     longitude of ascending node ( degrees , degrees / century )
                # omega       &omega;     argument of perihelion ( degrees )
                # m_cap       M           mean anomaly ( degrees )
                # e_cap       E           eccentric anomaly ( degrees )
                # delta_m_cap &delta;M    change in M ( degrees )
                # delta_e_cap &delta;E    change in E ( degrees )
                # t_cap       T           decimal number of centuries past J2000.0
                # mp_i                    planetary body index reference 0..8
                # mp                      planetary body name reference
                # e_star      e*          eccentricity * 180/pi ( degrees )


                # note: variable names follow naming from Standish paper.
                # *_cap means letter or variable capitalized (caps)
                # *_sym means letter in symbolic form (different than standard, such as pi_sym)
                # *_star means letter with asterisk suffix.
                # *_(other suffix) is standard tcl for subnotation, such as n_i for "n subscript i" etc.
                # *_arr indicates variable is an array
                # *_larr indicates variable is an array, where each array value is a list
                if { $use_table1_p } {
                    set alpha0 [lindex $table1_larr(${mp}) 0]
                    set alpha_rate [lindex $table1_larr(${mp}) 6]
                    set ecc0 [lindex $table1_larr(${mp}) 1]
                    set ecc_rate [lindex $table1_larr(${mp}) 7]
                    set iota_cap0 [lindex $table1_larr(${mp}) 2]
                    set iota_cap_rate [lindex $table1_larr(${mp}) 8]
                    set el_cap0 [lindex $table1_larr(${mp}) 3]
                    set el_cap_rate [lindex $table1_larr(${mp}) 9]
                    set py_sym0 [lindex $table1_larr(${mp}) 4]
                    set py_sym_rate [lindex $table1_larr(${mp}) 10]
                    set omega_cap0 [lindex $table1_larr(${mp}) 5]
                    set omega_cap_rate [lindex $table1_larr(${mp}) 11]
                } else {
                    set alpha0 [lindex $table2a_larr(${mp}) 0]
                    set alpha_rate [lindex $table2a_larr(${mp}) 6]
                    set ecc0 [lindex $table2a_larr(${mp}) 1]
                    set ecc_rate [lindex $table2a_larr(${mp}) 7]
                    set iota_cap0 [lindex $table2a_larr(${mp}) 2]
                    set iota_cap_rate [lindex $table2a_larr(${mp}) 8]
                    set el_cap0 [lindex $table2a_larr(${mp}) 3]
                    set el_cap_rate [lindex $table2a_larr(${mp}) 9]
                    set py_sym0 [lindex $table2a_larr(${mp}) 4]
                    set py_sym_rate [lindex $table2a_larr(${mp}) 10]
                    set omega_cap0 [lindex $table2a_larr(${mp}) 5]
                    set omega_cap_rate [lindex $table2a_larr(${mp}) 11]
                }

                set alpha [expr { $alpha0 + $t_cap * $alpha_rate } ]
                set ecc [expr { $ecc0 + $t_cap * $ecc_rate } ]
                set iota_cap [expr { $iota_cap0 + $t_cap * $iota_cap_rate } ]
                set el_cap [expr { $el_cap0 + $t_cap * $el_cap_rate } ]
                set pi_sym [expr { $py_sym0 + $t_cap * $py_sym_rate } ]
                set omega_cap [expr { $omega_cap0 + $t_cap * $omega_cap_rate } ]
                if { $ecc > 1 } {
                    # ecc cannot be > 1. for planetary bodies. log error
                    ns_log Warning "ssk::pos_kepler(264): ecentricity (ecc) gt 1. for body $mp use_table1_p $use_table1_p t_cap $t_cap "
                    if { $use_table1_p } {
                        ns_log Warning "ssk::pos_kepler(265): lindex table1_larr(${mp}) 1 '[lindex table1_larr(${mp}) 1]' lindex table1_larr(${mp}) 7 [lindex table1_larr(${mp}) 7]"
                    } else {
                        ns_log Warning "ssk::pos_kepler(266): lindex table2a_larr(${mp}) 2 '[lindex table2a_larr(${mp}) 1]' lindex table2a_larr(${mp}) 7 [lindex table2a_larr(${mp}) 7]"
                    }
                }

                # 2. Compute argument of perihelion (omega) and mean anomaly (m_cap), where
                #     omega = pi_sym - omega_cap  
                #
                #     m_cap = el_cap - pi_sym + b*pow(t_cap,2) + c*cos(f*t_cap) + s* sin(f*t_cap)
                #

                set omega [expr { $pi_sym - $omega_cap } ]
                set m_cap [expr { $el_cap - $pi_sym } ]
                # omega and m_cap are in degrees units

                if { !$use_table1_p } {
                    ns_log Notice "ssk::pos_kepler(352): Using table2"
                    # add Table2 additional terms, if existing
                    # terms from tabl2b
                    set b [lindex $table2b_larr(${mp}) 0]
                    set c [lindex $table2b_larr(${mp}) 1]
                    set s [lindex $table2b_larr(${mp}) 2]
                    set f [lindex $table2b_larr(${mp}) 3]
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
                
                # fmod doesn't work as the solution expects. Using a manual rotation calc instead.
                #set m_cap \[expr { fmod( $m_cap, 180.) } \]
                while { $m_cap < -180. } {
                    set m_cap [expr { $m_cap + 360. } ]
                }
                while { $m_cap > 180. } {
                    set m_cap [expr { $m_cap - 360. } ]
                }

                # 3b. Obtain the eccentric anomaly, e_cap from:
                #   Kepler's Equation:
                #     m_cap = e_cap - e_star * sin(e_cap) where e_star = 180*e/pi = 57.29578*e
                # From Standish paper,    Solution of Kepler's Equation. 
                # The obscurity of e_star can be dispelled via wikipedia's entry for Kepler's equation:
                # https://en.wikipedia.org/wiki/Kepler%27s_equation#Equation
                # m_cap = e_cap - e * sin(e_cap)
                # Therefore: e_cap = m_cap + e * sin(e_cap)
                
                #   Given:

                # alpha       semi-major axis (au, au / century)
                # ecc     eccentricity ( - , - / century )
                # iota_cap    inclination ( degrees, degrees / century )
                # el_cap      mean longitude ( degrees, degrees / century )
                # pi_sym      longitude of perihelion ( degrees , degrees / century )
                # omega_cap   longitude of ascending node ( degrees , degrees / century )

                #   m_cap  is mean anomaly in degrees
                #   e_star is eccentricity in degrees (ie ecc * $180perpi)
                set e_star [expr { $ecc * $180perpi } ]
                #   e_cap  is eccentric anomaly in radians

                # Start with e_cap_0 = m_cap + ecc * sin( m_cap / $180perpi )

                # Normally, use i for iteration, here using "n" per Standish paper
                set n 0
                set e_cap_n [expr { $m_cap + $ecc * sin( $m_cap / $180perpi) } ]

                set m_cap_n $m_cap
                # for diagnostics, save original value
                set m_cap_original $m_cap
                # interation calculations
                # tol is tollerance in degrees
                set tol 1.0e-6
                set abs_delta_e_cap [expr { $tol * 1.1 } ]

                set lc_limit 10000
                while { $abs_delta_e_cap > $tol && $n < $lc_limit } {
                    # These were the numerical approximation equations as understood from Standish paper only:
                    #set delta_m_cap \[expr { $m_cap - ( $e_cap_n - $e_star * sin( $e_cap_n / $180perpi ) ) } \]
                    #set delta_e_cap \[expr { $delta_m_cap / ( 1. - $ecc * cos( $e_cap_n / $180perpi ) ) } \]
                    # Standish restated:
                    set numerator [expr { $e_cap_n - $e_star * sin( $e_cap_n / $180perpi ) } ]
                    set delta_m_cap [expr { $m_cap_n - $numerator } ]
                    # case 1
                    set delta_e_cap [expr { $delta_m_cap  / ( 1. - $ecc * cos( $e_cap_n / $180perpi ) ) } ]
                    # or..
                    # case 2
                    #set delta_e_cap [expr { ( 0. - $numerator - $delta_m_cap ) / ( 1. - $ecc * cos( $e_cap_n / $180perpi ) ) } ]
                    # # The main difference between  these two sets of equations, is that 
                    # # m_cap is added in one delta_e_cap calc, or subtracted in the other.. verify
                    # case 2 causes planet to bob up and down in orbit.. must be case 1.

                    if { $Debug } {
                        ns_log Notice "ssk::pos_kepler(414): n $n delta_e_cap $delta_e_cap e_cap_n $e_cap_n"
                        ns_log Notice "ssk::pos_kepler(415): n $n delta_m_cap $delta_m_cap m_cap_n $m_cap_n "
                    }

                    set e_cap_n [expr { $e_cap_n + $delta_e_cap } ]
                    #set m_cap_n [expr { $m_cap_n + $delta_m_cap } ]
                    # assume m_cap doesn't iterate?
                    set abs_delta_e_cap [expr { abs( $delta_e_cap ) } ]
                    incr n
                    if { $n >= $lc_limit } {
                        ns_log Warning "ssk::pos_kepler interation limit of '${lc_limit}' reached, n '${n}' delta_e_cap '${delta_e_cap}' tol '${tol}'"
                    }
                }
                # eccentric anomoly is e_cap, assign from iteration
                if { $Debug } {
                    ns_log Notice "ssk::pos_kepler(434): $mp e_cap_n $e_cap_n m_cap_n $m_cap_n m_cap_original $m_cap_original"
                }
                set e_cap $e_cap_n
                # m_cap not used beyond this point.
                #set m_cap $m_cap_n

                # 4. Compute planet's heliocentric coordinates in its orbital plane, r_prime
                #    with x_prime axis aligned from the focus to the perhihelion.
                #    x_prime = a* (cos(E) - e) 
                #    y_prime = a* sqrt(1 - pow(e,2)) * sin(e_cap)
                #    z_prime = 0
                set e_cap_radians [expr { $e_cap / $180perpi } ]

                #set x_prime [expr { $alpha * ( cos( $e_cap_radians ) - $ecc ) } ]
                # https://en.wikipedia.org/wiki/Kepler%27s_equation#Equation shows equation differently:
                set x_prime [expr { $alpha * cos( $e_cap_radians - $ecc ) } ]
                set y_prime [expr { $alpha * sin( $e_cap_radians ) * sqrt( 1. - pow( $ecc , 2 ) ) } ]
                set z_prime 0.

                # 5. Compute coordinates, r_ecliptic in the J2000 ecliptic plane, with 
                #    x-axis aligned toward the equinox:

                set cos_omega [expr { cos( $omega / $180perpi ) } ]
                set sin_omega [expr { sin( $omega / $180perpi ) } ]
                set cos_omega_cap [expr { cos( $omega_cap / $180perpi ) } ]
                set sin_omega_cap [expr { sin( $omega_cap / $180perpi ) } ]
                set cos_iota_cap [expr { cos( $iota_cap / $180perpi ) } ]
                set sin_iota_cap [expr { sin( $iota_cap / $180perpi ) } ]
                if { $Debug } {
                    ns_log Notice "ssk::pos_kepler(473) $mp cos_omega $cos_omega"
                    ns_log Notice "ssk::pos_kepler(474) $mp sin_omega $sin_omega"
                    ns_log Notice "ssk::pos_kepler(475) $mp cos_omega_cap $cos_omega_cap"
                    ns_log Notice "ssk::pos_kepler(476) $mp sin_omega_cap $sin_omega_cap"
                    ns_log Notice "ssk::pos_kepler(477) $mp cos_iota_cap $cos_iota_cap"
                    ns_log Notice "ssk::pos_kepler(478) $mp sin_iota_cap $sin_iota_cap"
                    ns_log Notice "ssk::pos_kepler(479) $mp x_prime $x_prime"
                    ns_log Notice "ssk::pos_kepler(479) $mp y_prime $y_prime"
                    ns_log Notice "ssk::pos_kepler(480) $mp z_prime $z_prime"
                }
                                                                                                                                

                # x_ecl = (cos(omega) *cos(omega_cap) - sin(omega)*sin(omega_cap)*cos(iota_cap) ) * x_prime 
                #         + ( -1 * sin(omega)*cos(omega_cap)-cos(omega)*sin(omega_cap)*cos(iota_cap) ) * y_prime
                # y_ecl = (cos(omega) *sin(omega_cap) + sin(omega)*cos(omega_cap)*cos(iota_cap) ) * x_prime 
                #         + ( -1 * sin(omega)*sin(omega_cap)+cos(omega)*cos(omega_cap)*cos(iota_cap) ) * y_prime
                # z_ecl = (sin(omega)*sin(iota_cap)) * x_prime + (cos(omega)*sin(iota_cap) ) * y_prime
                set x_ecl [expr { ( $cos_omega * $cos_omega_cap - $sin_omega * $sin_omega_cap * $cos_iota_cap ) * $x_prime \
                                      + ( -1. * $sin_omega * $cos_omega_cap - $cos_omega * $sin_omega_cap * $cos_iota_cap ) * $y_prime } ]
                set y_ecl [expr { ( $cos_omega * $sin_omega_cap + $sin_omega * $cos_omega_cap * $cos_iota_cap ) * $x_prime \
                                      + ( -1. * $sin_omega * $sin_omega_cap + $cos_omega * $cos_omega_cap * $cos_iota_cap ) * $y_prime } ]
                set z_ecl [expr { ( $sin_omega * $sin_iota_cap ) * $x_prime \
                                      + ( $cos_omega * $sin_iota_cap ) * $y_prime } ]
                #ns_log Notice "ssk::pos_kepler(507): time_s $time_s t_cache $t_cache"

                set pos_k_arr(${mp},${t_cache},0) [list $x_ecl $y_ecl $z_ecl]
            } 
            if { $icrf_p } {
                # Convert from equatorial coordinates to ecliptic coordinates
                # See https://en.wikipedia.org/wiki/Ecliptic_coordinate_system#Conversion_from_equatorial_coordinates_to_ecliptic_coordinates

                # see if value already exists.
                # for diagnostics, don't use cache
                if { ![info exists $pos_k_arr(${mp},${t_cache},1) ] || 1 } {
                    # transform to ICRF/J2000 frame format
                    # we can't depend on prior x_ecl,y_ecl,z_ecl, because value may have been previously calculated.
                    set ecl_list $pos_k_arr(${mp},${t_cache},0)
                    set x_ecl [lindex $ecl_list 0]
                    set y_ecl [lindex $ecl_list 1]
                    set z_ecl [lindex $ecl_list 2]
                    set x_eq $x_ecl
                    set cos_epsilon [expr { cos($icrf1_epsilon_deg / $180perpi ) } ]
                    set sin_epsilon [expr { sin($icrf1_epsilon_deg / $180perpi ) } ]
                    set y_eq [expr { $cos_epsilon * $y_ecl - $sin_epsilon * $z_ecl } ]
                    # Wikipedia suggests following calc should be: + $cos_epsilon * $z_ecl, instead of - ...
                    set z_eq [expr { $sin_epsilon * $y_ecl - $cos_epsilon * $z_ecl } ]
                    set pos_k_arr(${mp},${t_cache},1) [list $x_eq $y_eq $z_eq]
                }
                set temp_larr(${mp}) $pos_k_arr(${mp},${t_cache},1)
            } else {
                set temp_larr(${mp}) $pos_k_arr(${mp},${t_cache},0)
            }

        }
    }
    set Debug 0
    return $success_p
}
