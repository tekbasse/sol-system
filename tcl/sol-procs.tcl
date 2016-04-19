#/sol-system/tcl/sol-procs.tcl
ad_library {

    Sol System package procedures
    @creation-date 3 Apr 2016
    @cvs-id $Id:
    @Copyright (c) 2016 Benjamin Brink
    @license GNU General Public License 3, see project home or http://www.gnu.org/licenses/gpl-3.0.en.html
    @project home: http://github.com/tekbasse/sol-system
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com

    Temporary comment about git commit comments: http://xkcd.com/1296/
}

# These are calculations about the Sun

namespace eval ::ssk {}

ad_proc -public ssk::sol_earth_latitude {
    time_utc
    {utc_format "%Y-%h-%d %H:%M:%S"}
} {
    Finds the angle of the Earth above or below the Solar equatorial plane.
    This is the same as finding the latitude of an observer on the Sun with Earth at Zenith.
} {
    # Sun is at origin (0,0,0)
    # get Solar pole orientation
    # Solar pole is given as Right Ascention, Declination in Celestial Sphere coordinates (Geo-equatorial)
    # ::ssk::table6_larr(Sun)
    # table6 variable order: alpha_0 alpha_dot delta_0 delta_dot w_cap_0 w_cap
    # where
    #        alpha_0       position of the North pole in Right Ascension ( degrees ) 
    #        delta_0       position of the North pole in Declination ( degrees )
    #        alpha_dot     change in Right Ascension position ( degrees per century J2000 )
    #        detla_dot     change in Declination position ( degrees per century J2000 )
    #        w_cap_0       position of the prime meridian at GEI J2000 ( degrees )
    #        w_cap         change in position ( degrees per day )
    variable ::ssk::table6_larr
    variable ::ssk::km_per_au
    variable ::ssk::180perpi
    variable ::ssk::temp2_larr

    if { [info exists $temp2_larr(${time_utc}) ] } {
        set solar_lat_deg [lindex $temp2_larr(${time_utc}) 0 ]
        set solar_disc_tilt_deg [lindex $temp2_larr(${time_utc}) 1 ]
        set relative_pole_radius [lindex $temp2_larr(${time_utc}) 2]
    } else {

        set days_since_j2000 [ssk::days_since_j2000 $time_utc]
        #set days_since_j2000 \[expr { $j2000_time - 2451545.0 } \]
        set t_cap [expr { $days_since_j2000 / 36525. } ]

        set alpha_0 [lindex $table6_larr(Sun) 0]
        set alpha_dot [lindex $table6_larr(Sun) 1]
        set delta_0 [lindex $table6_larr(Sun) 2]
        set delta_dot [lindex $table6_larr(Sun) 3]
        set w_cap_0 [lindex $table6_larr(Sun) 4]
        set w_cap_per_day [lindex $table6_larr(Sun) 5]

        set alpha [expr { $alpha_0 + $alpha_dot * $t_cap } ]
        set delta [expr { $delta_0 + $delta_dot * $t_cap } ]
        set w_cap [expr { $w_cap_0 + $w_cap_per_day * $days_since_j2000 } ]
        set w_cap [ssk::unwind $w_cap 0. 360.]


        # Solar equator is the plane defined as perpendicular (orthogonal) to a polar oriented vector
        # given a vector N1,N2,N3, plane is equation N1*x + N2*y + N3*z = 0

        # convert polar coordinates of sol's pole coordinates (in Geo RA, Dec) to Cartesian J2000
        # Let's assume r is radius of Sol.
        set sol_r_au [expr { 695700. / $km_per_au } ]
        
        # using spherical polar coordinates to Cartesian transformations,
        # where theta = 90 degrees - Dec angle, thus sin(theta) becomes cos(Dec Angle):
        # x = r * cos( Dec angle ) * cos ( Right accension angle)
        # y = r * cos( Dec angle ) * sin ( righ accension angle )
        # z = r * sin( Dec angle )
        set cos_dec_angle [expr { cos( $delta / $180perpi ) } ]
        set n_x_au [expr { $sol_r_au * $cos_dec_angle * cos( $alpha / $180perpi ) } ]
        set n_y_au [expr { $sol_r_au * $cos_dec_angle * sin( $alpha / $180perpi ) } ]
        set n_z_au [expr { $sol_r_au * sin( $delta / $180perpi ) } ]

        # get position of Earth in x y z coordinates
        ssk::pos_kepler $time_utc Earth e_larr 0
        # Since Sun is at origin (0,0,0), the angle of the line that intersects the Solar equatorial plane
        # is the solar latitude of Earth at Zenith if observer is at Sun.
        # A line through origin is defined by delta X + delta Y + delta Z = 0, or since origin is 0,0,0:
        set e_x_au [lindex $e_larr 0]
        set e_y_au [lindex $e_larr 1]
        set e_z_au [lindex $e_larr 2]
        
        # given a plane with perpenicular vector from origin to N1,N2,N3, and a line
        # from origin to U1,U2,U3
        # latitude angle =
        #    arcsin(  ( N1*U1 + N2*U2 + N3*U3 ) / ( sqrt( pow(N1,2) + pow(N2,2) + pow(N3,2) ) * sqrt(pow(u1,2)+pow(u2,2)+pow(u3,2) ) ) )
        # geometry reference: http://www.vitutor.com/geometry/distance/line_plane.html
        # Here N1,N2,N3 = n_x_au,n_y_au,n_z_au  and U1,U2,U3 = e_x_au,e_y_au,e_z_au 

        # caching some values, initially for repeated use later, but also helps show that
        # switching the parameters for e_ and n_ vectors result in same value
        set e_magnitude [expr { sqrt( pow( $e_x_au , 2 ) + pow( $e_y_au , 2 ) + pow( $e_z_au ) ) } ]
        set n_magnitude [expr { sqrt( pow( $n_x_au , 2 ) + pow( $n_y_au , 2 ) + pow( $n_z_au ) ) } ]

        set factor_block1 [expr { ( $n_x_au * $e_x_au + $n_y_au * $e_y_au + $n_z_au * $e_z_au ) / ( $n_magnitude * $e_magnitude ) } ]
        set solar_lat_rad [expr { asin( $factor_block1 ) } ]
        set solar_lat_deg [expr { $solar_lat_rad * $180perpi } ]


        # Data should be available here to also calculate the tilt of the solar northern pole 
        # as seen from the solar disc from Earth's perspective.
        # ie. the solar North pole vector projected onto the plane passing through the ecliptic origin (Sun) and 
        # perpendicular (orthogonal) to the Sun-Earth vector.

        # ie find: D_vector

        # One way is:
        # given:  n_vector as the cartesian solar Northpole vector
        #         e_vector as the Cartesian Sun-Earth vector
        #         g_vector as Earth's North pole vector         

        # create a C_vector by
        #  adjusting e_vector's magnitude so that n_vector = C_vector + D_vector
        # or D_vector = n_vector - C_vector

        #  C_vector is parallel to e_vector

        #    convert e_vector to a unit vector u_e_vector
        set u_e_x_au [expr { $e_x_au / $e_magnitude } ]
        set u_e_y_au [expr { $e_y_au / $e_magnitude } ]
        set u_e_z_au [expr { $e_z_au / $e_magnitude } ]

        # The magnitude of C_vector can be determined by taking the sin of
        # the angle of the intersection of n_vector with plane defined by e_vector.
        # Let's call this angle: nv_eplane_rad   ( *_rad for radians)

        # Using the same forumla for calculating the intersection of n_vector with plane defined by e_vector,
        # Here N1,N2,N3 = e_x_au,e_y_au,e_z_au  and U1,U2,U3 = n_x_au,n_y_au,n_z_au 
        # ie swap parameters of prior use of angle between line and plane solution in this procedure.
        # set nv_eplane_rad \[expr { asin( ( $n_x_au * $e_x_au + $n_y_au * $e_y_au + $n_z_au * $e_z_au ) / ( $n_magnitude * $e_magnitude ) ) } \]

        # swapping the parameters, the result is the same, so simplifying to:
        set nv_eplane_rad $solar_lat_rad

        # set d_magnitude \[expr { sin($nv_eplane_rad) * $n_magnitude } \]
        # Note that the calculation of the first factor is essentially the same as calcing solar_lat_rad less the last step, ie
        # calcing factor_block1, so we save some calc time by inserting the prior calced value here:
        set d_magnitude [expr { $factor_block1 * $n_magnitude } ]
        # We can use $d_magnitude to check final results, but not immediately useful to obtain the angle needed for D_vector
        # We know c_vector direction, so calculate c_magnitude
        set c_magnitude [expr { cos( asin( $factor_block1) ) * $n_magnitude } ]
        # Now we can make C_vector:
        set c_x_au [expr { $u_e_x_au * $c_magnitude } ]
        set c_y_au [expr { $u_e_y_au * $c_magnitude } ]
        set c_z_au [expr { $u_e_z_au * $c_magnitude } ]

        # Restated from above: D_vector = n_vector - C_vector
        # D_vector equals:
        set d_x_au [expr { $n_x_au - $c_x_au } ]
        set d_y_au [expr { $n_y_au - $c_y_au } ]
        set d_z_au [expr { $n_z_au - $c_z_au } ]

        ## At some point, it may make more sense to convert to km instead of au.

        ## Here we could add a sanity check, d_magnitude <= $sol_r_au
        ## and check D_vector's magnitude against prior calculated $d_magnitude

        # D_vector is on plane defined by e_vector (essentially solar disc image)

        # table6_larr(Earth) contains orientation of Earth's North pole ( g_vector )
        # Following code essentially duplicates table6 calcs in first part of this procedure,
        # which warrants creating a separate procedure.  However,
        # calculations are kept in context for complete perspective.
        set alpha_0 [lindex $table6_larr(Earth) 0]
        set alpha_dot [lindex $table6_larr(Earth) 1]
        set delta_0 [lindex $table6_larr(Earth) 2]
        set delta_dot [lindex $table6_larr(Earth) 3]
        set w_cap_0 [lindex $table6_larr(Earth) 4]
        set w_cap_per_day [lindex $table6_larr(Earth) 5]

        set alpha [expr { $alpha_0 + $alpha_dot * $t_cap } ]
        set delta [expr { $delta_0 + $delta_dot * $t_cap } ]
        set w_cap [expr { $w_cap_0 + $w_cap_per_day * $days_since_j2000 } ]
        set w_cap [ssk::unwind $w_cap 0. 360.]

        # Earth equator is the plane defined as perpendicular (orthogonal) to a polar oriented vector
        # given a vector N1,N2,N3, plane is equation N1*x + N2*y + N3*z = 0

        # convert polar coordinates of Earth's North pole coordinates (in Geo RA, Dec) to Cartesian J2000
        # Let's assume r is radius of Earth.
        set gaia_r_au [expr { 6371. / $km_per_au } ]
        
        # using spherical polar coordinates to Cartesian transformations,
        # where theta = 90 degrees - Dec angle, thus sin(theta) becomes cos(Dec Angle):
        # x = r * cos( Dec angle ) * cos ( Right accension angle)
        # y = r * cos( Dec angle ) * sin ( righ accension angle )
        # z = r * sin( Dec angle )
        set cos_dec_angle [expr { cos( $delta / $180perpi ) } ]
        set g_x_au [expr { $gaia_r_au * $cos_dec_angle * cos( $alpha / $180perpi ) } ]
        set g_y_au [expr { $gaia_r_au * $cos_dec_angle * sin( $alpha / $180perpi ) } ]
        set g_z_au [expr { $gaia_r_au * sin( $delta / $180perpi ) } ]
        # g_vector needs to be projected into the same plane as defined by e_vector for viewing perpsective.
        # Call the projected g_vector onto the solar disc.. g_sd_vector

        # given a plane with perpenicular vector from origin to N1,N2,N3, and a line
        # from origin to U1,U2,U3
        # latitude angle =
        #    arcsin(  ( N1*U1 + N2*U2 + N3*U3 ) / ( sqrt( pow(N1,2) + pow(N2,2) + pow(N3,2) ) * sqrt(pow(u1,2)+pow(u2,2)+pow(u3,2) ) ) )
        # geometry reference: http://www.vitutor.com/geometry/distance/line_plane.html
        # Here N1,N2,N3 = g_x_au,g_y_au,g_z_au  and U1,U2,U3 = u_e_x_au,u_e_y_au,u_e_z_au 

        #  u_e_magnitude = 1
        set g_magnitude [expr { sqrt( pow( $g_x_au , 2 ) + pow( $g_y_au , 2 ) + pow( $g_z_au ) ) } ]

        set factor_block2 [expr { ( $g_x_au * $e_x_au + $g_y_au * $e_y_au + $g_z_au * $e_z_au ) / ( $g_magnitude * $e_magnitude ) } ]
        set gaia_lat_rad [expr { asin( $factor_block2 ) } ]
        set gaia_lat_deg [expr { $gaia_lat_rad * $180perpi } ]

        # Repeating use of D_vector (now m_vector) and C_vector (now p_vector) in context of g_vector instead of n_vector:
        # Angle between m_vector and g_vector = apparent angle of Sun's North pole from Earth's polar North.

        # create a p_vector by
        #  adjusting e_vector's magnitude so that g_vector = p_vector + m_vector
        # or m_vector = g_vector - p_vector

        #  p_vector is parallel to e_vector

        #    convert e_vector to a unit vector u_e_vector
        # (Already defined from prior calcuations )
        #set u_e_x_au [expr { $e_x_au / $e_magnitude } ]
        #set u_e_y_au [expr { $e_y_au / $e_magnitude } ]
        #set u_e_z_au [expr { $e_z_au / $e_magnitude } ]

        # The magnitude of p_vector can be determined by taking the sin of
        # the angle of the intersection of g_vector with plane defined by e_vector.
        # Let's call this angle: gv_eplane_rad   ( *_rad for radians)

        # Using the same forumla for calculating the intersection of g_vector with plane defined by e_vector,
        # Here N1,N2,N3 = e_x_au,e_y_au,e_z_au  and U1,U2,U3 = g_x_au,g_y_au,g_z_au 
        # ie swap parameters of prior use of angle between line and plane solution in this procedure.
        # set gv_eplane_rad \[expr { asin( ( $g_x_au * $e_x_au + $g_y_au * $e_y_au + $g_z_au * $e_z_au ) / ( $g_magnitude * $e_magnitude ) ) } \]

        # swapping the parameters, the result is the same, so simplifying to:
        set gv_eplane_rad $gaia_lat_rad

        # set d_magnitude \[expr { sin($nv_eplane_rad) * $n_magnitude } \]
        # Note that the calculation of the first factor is essentially the same as calcing gaia_lat_rad less the last step, ie
        # calcing factor_block2, so we save some calc time by inserting the prior calced value here:
        set m_magnitude [expr { $factor_block2 * $g_magnitude } ]
        # We can use $d_magnitude to check final results, but not immediately useful to obtain the angle needed for m_vector
        # We know p_vector direction, so calculate c_magnitude
        set p_magnitude [expr { cos( asin( $factor_block2) ) * $g_magnitude } ]
        # Now we can make p_vector:
        set p_x_au [expr { $u_e_x_au * $p_magnitude } ]
        set p_y_au [expr { $u_e_y_au * $p_magnitude } ]
        set p_z_au [expr { $u_e_z_au * $p_magnitude } ]

        # Restated from above: m_vector = g_vector - p_vector
        # m_vector equals:
        set m_x_au [expr { $g_x_au - $p_x_au } ]
        set m_y_au [expr { $g_y_au - $p_y_au } ]
        set m_z_au [expr { $g_z_au - $p_z_au } ]

        # Angle of D_vector - M_vector is the relative counter-clockwise angle between Earth North Pole and 
        # Solar North Pole as seen on Solar disc

        # The angle can be determined using these vector dot product formulas:
        #  dot( v_vector, w_vector ) / ( magnitude( v_vector) * magnitude( w_vector ) ) = cos( angle between v_vector and w_vector)
        # and
        #  dot( v_vector, w_vector ) = Vx * Wx + Vy * Wy + Vz * Wz
        #
        # becomes:
        # angle = acos( (Vx * Wx + Vy * Wy + Vz * Wz) / (magnitude( v_vector) * magnitude( w_vector ) ) )
        set solar_disc_tilt_rad [expr { acos( ($m_x_au * $d_x_au + $m_y_au * $d_y_au + $m_z_au * $d_z_au ) / ( $m_magnitude * $d_magnitude ) ) } ]
        set solar_disc_tilt_deg [expr { $solar_disc_tilt_rad * $180perpi } ]
        set relative_pole_radius [expr { $d_magnitude / $sol_r_au } ]
        set return_list [list $solar_lat_deg $solar_disc_tilt_deg $relative_pole_radius]

        # These results should be cached.
        set temp2_larr({$time_utc}) $return_list
    }
    return $return_list
}


ad_proc -public ssk::sol_tranx_disc_to_3d {
    x
    y
    diameter_px
    time_utc
    {utc_format "%Y-%h-%d %H:%M:%S"}
} {
    Determines solar latitude and longitude according to 0degrees Earth at Zenith perspective, 
    given a time_utc, position x,y and diameter of image in pixels
    Origin p(0,0) is assumed to be upper left, with center of disc at diameter_px/2. x > 0 and y > 0
} {
    variable ::ssk::180perpi
    # Would be ideal to have a proc that converts solar disc x,y (at Earth's perspective) to solar coordinates
    # for now can settle having solar latitude and solar longitude according to 0degrees Earth perspective.

    # Origin p(0,0) is assumed to be upper left, with center of disc at diameter_px/2. x > 0 and y > 0
    set temp_list [ssk::sol_earth_latitude $time_utc $utc_format]
    set solar_lat_deg [lindex $temp_list 0]
    set solar_disc_tilt_deg [lindex $temp_list 1]
    set relative_pole_radius [lindex $temp_list 2]

    
    # transform p(x,y) to p2(x,y) where solar North is up (X positive)
    # 2D polar transform.
    # This could be tweeked for oblateness by specifying a different diameter and height.
    #
    # determine dec, right acsention angle
    set sol_r_px [expr { $diameter_px / 2. } ]
    set x_center_px $radius_px
    set y_center_px $radius_px
    set dx [expr { $x - $x_center_px } ]
    set dy [expr { $y - $y_center_px } ]
    set xy_radius_px [expr { sqrt( pow( $dx, 2 ) + pow( $dy, 2 ) ) } ]
    set xy_angle_rad [expr { acos( $dx / $xy_radius_px ) } ]
    set xy_angle2_rad [expr { $xy_angle_rad - $solar_disc_tilt_deg / $180perpi } ]

    # rotate (transform)
    set dx2_px [expr { $xy_radius_px * cos( $xy_angle2_rad ) } ]
    set dy2_px [expr { $xy_radius_px * sin( $xy_angle2_rad ) } ]


    # Determine declination angle dec_rad
    # asin( dy2_px / height of disc at dx2_px )
    # height is the same as sol_r_px * sin(theta), where theta = acos( dx2_px / sol_r_px )
    set disc_r_at_dx2 [expr { $sol_r_px * sin( acos( $dx2_px / $sol_r_px ) ) } ]
    set dec_rad [expr { asin( $dy2_px / $disc_r_at_dx2 ) } ]

    # Adjust dec according to solar tilt away from (or toward) Earth. This angle
    # is the same as ssk::sol_earth_latitude of observer on Sun with Earth at Zenith 
    # Negative is Earth below solar equator (move reference down same angle). 
    set dec_deg [expr { $dec_rad * $180perpi + $solar_lat_deg } ]

    # determine Right Ascention angle
    set disc_r_at_dy2 [expr { $sol_r_px * cos( asin( $dy2_px / $sol_r_px ) ) } ]
    set ra_rad [expr { acos( $dx2_px / $disc_r_at_dy2 ) } ]
    set ra_deg [expr { $ra_rad * $180perpi } ]

    # set p(x2,y2)
    # set x2 \[expr { $dx2_px + $xy_radius_px } \]
    # set y2 \[expr { $dy2_px + $xy_radius_px } \]

    set return_list [list $dec_deg $ra_deg ]

    return $return_list
}


ad_proc -public ssk::earth_sol_latitude {
    time_utc
    {utc_format "%Y-%h-%d %H:%M:%S"}
} {
    Finds the position of the Sun (Right Ascention and Declination) in the celestial sphere and other related info
    Returns list: RA (hours), DEC (degrees), apparent arc diameter (degrees), Earth-Sun distance (AU)
} {
    variable ::ssk::180perpi
    ## following are notes originally from:
    ##  USNO Astronomical Applications Dept
    ##  Approximate Solar Coordinates page
    ##  retrieved from http://aa.usno.navy.mil/faq/docs/SunApprox.php

    ## D = JD - 2451545.0
    # see
    set days_since_j2000 [ssk::days_since_j2000 $time_utc]
    #set days_since_j2000 [expr { $j2000_time - 2451545.0 } ]

    #Then compute

    # Mean anomaly of the Sun:
    # g = 357.529 + 0.98560028 D
    set g_deg [expr { 357.529 + 0.98560028 * $days_since_j2000 } ]

    # Mean longitude of the Sun:
    # q = 280.459 + 0.98564736 D
    set q_deg [expr { 280.459 + 0.98564736 * $days_since_j2000 } ]

    # Geocentric apparent ecliptic longitude
    # of the Sun (adjusted for aberration):
    # L = q + 1.915 sin g + 0.020 sin 2g
    # where all the constants (therefore g, q, and L) are in degrees. 

    # It may be necessary or desirable to reduce g, q, and L to the range 0 to 360 degrees
    set q_deg [ssk::unwind $q_deg 0. 360.]
    set g_deg [ssk::unwind $g_deg 0. 360.]
    set l_deg [expr { $q_deg + 1.915 * sin( $g_deg / $180perpi )  + 0.020 sin( 2. * $g_deg / $180perpi) } ]
    set l_deg [ssk::unwind $l_deg 0. 360.]


    # The Sun's ecliptic latitude, b, can be approximated by b=0. 
    set b 0.
    # The distance of the Sun from the Earth, R, in astronomical units (AU), can be approximated by
    # R = 1.00014 - 0.01671 *cos (g ) - 0.00014 * cos(2*g)
    set r_au [expr { 1.00014 - 0.01671 * cos($g_deg / $180perpi ) - 0.00014 * cos( 2. * $g_deg / $180perpi) } ]
    # Once the Sun's apparent ecliptic longitude, L, has been computed, 
    # the Sun's right ascension and declination can be obtained. 

    # First compute the mean obliquity of the ecliptic, in degrees:
    # e = 23.439 - 0.00000036 D
    set e_deg [expr { 23.439 - 0.00000036 * $days_since_j2000 } ]
    #Then the Sun's right ascension, RA, and declination, d, can be obtained from
    #tan RA = cos e sin L / cos L
    #sin d = sin e sin L
    set sin_l [expr { sin( $l_deg / $180perpi ) } ]
    set sol_ra_deg [expr { $180perpi * atan2( cos( $e_deg / $180perpi) * $sin_l , cos( $l_deg / $180perpi ) ) } ]
    set sol_dec_deg [expr { $180perpi * asin( sin( $e_deg / $180perpi) * $sin_l ) } ]
    
    #RA is always in the same quadrant as L. 
    # If the numerator and denominator on the right side of the expression for RA are used in a double-argument arctangent function
    # (e.g., "atan2"), the proper quadrant will be obtained. 

    # If RA is obtained in degrees, it can be converted to hours by dividing by 15. 
    # RA is conventionally reduced to the range 0 to 24 hours
    set sol_ra_hours [expr { $sol_ra_deg / 15. } ]
    # Other quantities can also be obtained. 
    # The Equation of Time, EqT, apparent solar time minus mean solar time, can be computed from
    # EqT = q/15 - RA
    # where Eqt and RA are in hours and q is in degrees. 
    # More at http://aa.usno.navy.mil/faq/docs/eqtime.php
    
    # The angular semidiameter of the Sun, SD, in degrees, is simply
    # SD = 0.2666 / R   or between 0.52 and 0.545 degrees of arc
    set sol_diameter_deg [expr { 0.2666 / $r_au } ]
    #This algorithm is essentially the same as that found on page C5 of The Astronomical Almanac; 
    # a few constants have been adjusted above to extend the range of years for which the algorithm is valid.
    ## end of quoted material from unso sol page.
    set return_list [list $sol_ra_hours $sol_dec_deg $sol_diameter_deg $r_au]
    return $return_list
}


ad_proc -public ssk::unwind {
    deg
    {min "0."}
    {max "360."}
} {
    Rotates angle until within range 0 to 360 (or -180 to 180).. etc.
} {
    set min [expr { $min + 0. } ]
    set max [expr { $max + 0. } ]
    # catch spin condition, return unchanged
    if { $max > $min } {
        set range [expr { $max - $min } ]
        
        while { $deg < $min } {
            set deg [expr { $deg + $range } ]
        }
        while { $deg > $max } {
            set deg [expr { $deg - $range } ]
        }
    }
    return $deg
}
